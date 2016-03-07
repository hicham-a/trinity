#!/bin/bash
set -x
# if command starts with an option, prepend mysqld
if [ "${1:0:1}" = '-' ]; then
        set -- mysqld "$@"
fi

bootstrap=()
for i in "$@"; do
    case $i in
    --wsrep_cluster_address=*)
        CLUSTERADDRESS="${i#*=gcomm://}"
        bootstrap+=(--wsrep_cluster_address=gcomm://)
        ;;
    *)
        bootstrap+=($i)
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
        grep "WSREP: New cluster view:" /tmp/mysql.log && break
    done
    ps -ef
    kill -SIGTERM ${pid}
    for i in {30..0}; do
       kill -s 0 ${pid} || break
    done
    ps -ef
    [[ $i = 0 ]] && kill -SIGKILL ${pid}
    ps -ef

    if grep "WSREP: New cluster view" /tmp/mysql.log | grep "non-Primary" ; then
        exec "${bootstrap[@]}"
    else
        exec "$@"
    fi
else
    exec "$@"
fi
