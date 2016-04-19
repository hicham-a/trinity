#!/bin/bash
#set -e 
set -x

sed -e "s/<HOST_IP>/10.141.255.254/g" -i /etc/glance/glance-api.conf
sed -e "s/<HOST_IP>/10.141.255.254/g" -i /etc/glance/glance-registry.conf

chown glance:glance /etc/glance/glance-api.conf
chown glance:glance /etc/glance/glance-registry.conf
chown -R glance:glance /var/lib/glance
su -s /bin/sh -c "glance-manage db_sync" glance

exec "$@"
