#!/bin/bash
set -x
read ETH0 ETH1 ETH2 <<<$(ls /sys/class/net/ | grep "^e" | sort | head -3)
sed -e "s/\<ETH0\>/${ETH0}/g" -e "s/\<ETH1\>/${ETH1}/g"  -e "s/\<ETH2\>/${ETH2}/g" -i /etc/nova/nova.conf
sed -e "s/<HOST_IP>/10.141.255.254/g" -i /etc/nova/nova.conf

chown -R nova:nova /var/log/nova
chown nova:nova /etc/nova/nova.conf
chown -R nova:nova /var/lib/nova
su -s /bin/sh -c "nova-manage db sync" nova

exec "$@"
