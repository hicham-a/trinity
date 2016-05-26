#! /usr/bin/env bash

KS_CONT="keystone"
obol -H ldap://controller -w $LDAP_ADMIN_PW user add glance --password $OPENSTACK_GLANCE_PW --cn glance --sn glance --givenName glance
docker exec ${KS_CONT} keystone --os-token $OPENSTACK_ADMIN_TOKEN --os-endpoint http://$CONTROLLER_FIP:35357/v2.0 user-role-add --user glance --tenant service --role admin
docker exec ${KS_CONT} keystone --os-token $OPENSTACK_ADMIN_TOKEN --os-endpoint http://$CONTROLLER_FIP:35357/v2.0 service-create --name glance --type image --description "OpenStack Image Service"
SERVICE_ID=$(docker exec ${KS_CONT} keystone --os-token $OPENSTACK_ADMIN_TOKEN --os-endpoint http://$CONTROLLER_FIP:35357/v2.0 service-list | awk '/ image / {print $2}')
docker exec ${KS_CONT} keystone --os-token $OPENSTACK_ADMIN_TOKEN --os-endpoint http://$CONTROLLER_FIP:35357/v2.0 endpoint-create --service-id "${SERVICE_ID}" --publicurl http://$CONTROLLER_FIP:9292 --internalurl http://$CONTROLLER_FIP:9292 --adminurl http://$CONTROLLER_FIP:9292 --region regionOne
