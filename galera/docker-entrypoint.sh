#!/bin/bash
set -x
# if command starts with an option, prepend mysqld
if [ "${1:0:1}" = '-' ]; then
        set -- mysqld "$@"
fi

for i in "$@"
do
case $i in
    --wsrep_cluster_address=*)
    CLUSTERADDRESS="${i#*=gcomm://}"
    echo $CLUSTERADDRESS
    ;;
esac
done

IFS=',' read -ra NODES <<< "$CLUSTERADDRESS"
echo ${NODES[0]}

if hostname -I | grep ${NODES[0]}; then
    echo "I am the master node"
    "$@" > /tmp/mysql.log 2>&1 &
    pid=$!
    echo PID ${pid}

    for i in {30..0}; do
        sleep 3 
        if grep "WSREP: New cluster view:" /tmp/mysql.log; then
            break
        fi
    done
    ps -ef
    kill -SIGTERM ${pid}
    #wait ${pid}
    killall mysqld
    sleep 30
    kill -KILL ${pid}
    ps -ef
    netstat -anp | grep LIST
    if grep "WSREP: New cluster view" /tmp/mysql.log | grep "non-Primary" ; then
        exec mysqld --wsrep_cluster_address=gcomm:// --wsrep_cluster_name=trinity --wsrep_node_address=$(hostname -i)
    else
        exec "$@"
    fi
else
    exec "$@"
fi
