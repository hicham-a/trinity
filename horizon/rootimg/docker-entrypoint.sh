#!/bin/bash
set -e 

sed -e "s/<HOST_IP>/$(hostname -i)/g" -i /etc/openstack-dashboard/local_settings
setsebool -P httpd_can_network_connect on
chown -R apache:apache /usr/share/openstack-dashboard/static

# This is to fix a bug in the httpd configuration needed for Juno
echo 'Include "/etc/httpd/conf.modules.d/*.conf"' >> /etc/httpd/conf/httpd.conf

exec "$@"
