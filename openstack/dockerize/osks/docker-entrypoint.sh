#!/bin/bash
set -e

#if [ "${1:0:1}" = '-' ]; then
#	set -- /usr/bin/keystone-all "$@"
#fi
#
#if [ "$1" = '/usr/bin/keystone-all' ]; then
#  /usr/bin/openstack-config --set /etc/keystone/keystone.conf DEFAULT admin_token system
#  /usr/bin/openstack-config --set /etc/keystone/keystone.conf database connection mysql://keystone:system@10.141.0.1/keystone
#  /usr/bin/openstack-config --set /etc/keystone/keystone.conf token provider keystone.token.providers.uuid.Provider
#  /usr/bin/openstack-config --set /etc/keystone/keystone.conf token driver  keystone.token.persistence.backends.sql.Token
#  /usr/bin/openstack-config --set /etc/keystone/keystone.conf revoke driver  keystone.contrib.revoke.backends.sql.Revoke
#  /usr/bin/openstack-config --set /etc/keystone/keystone.conf DEFAULT verbose True

keystone-manage pki_setup --keystone-user keystone --keystone-group keystone
chown -R keystone:keystone /var/log/keystone
chown -R keystone:keystone /etc/keystone/ssl
chmod -R o-rwx /etc/keystone/ssl
chown keystone:keystone /etc/keystone/keystone.conf
chown -R keystone:keystone /var/lib/keystone
su -s /bin/sh -c "/usr/bin/keystone-manage db_sync" keystone
#fi

exec "$@"
