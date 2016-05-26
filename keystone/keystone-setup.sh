#! /usr/bin/env bash

KS_CONT="keystone"
docker exec ${KS_CONT} keystone --os-token $OPENSTACK_ADMIN_TOKEN --os-endpoint http://$CONTROLLER_FIP:35357/v2.0 tenant-create --name admin --description "Admin Tenant"
obol -H ldap://controller -w $LDAP_ADMIN_PW user add "admin" --password $OPENSTACK_ADMIN_PW --cn "admin" --sn "admin" --givenName "admin"
docker exec ${KS_CONT} keystone --os-token $OPENSTACK_ADMIN_TOKEN --os-endpoint http://$CONTROLLER_FIP:35357/v2.0 role-create --name admin
docker exec ${KS_CONT} keystone --os-token $OPENSTACK_ADMIN_TOKEN --os-endpoint http://$CONTROLLER_FIP:35357/v2.0 role-create --name _member_
docker exec ${KS_CONT} keystone --os-token $OPENSTACK_ADMIN_TOKEN --os-endpoint http://$CONTROLLER_FIP:35357/v2.0 user-role-add --user admin --tenant admin --role admin
docker exec ${KS_CONT} keystone --os-token $OPENSTACK_ADMIN_TOKEN --os-endpoint http://$CONTROLLER_FIP:35357/v2.0 tenant-create --name service --description "Service Tenant"
docker exec ${KS_CONT} keystone --os-token $OPENSTACK_ADMIN_TOKEN --os-endpoint http://$CONTROLLER_FIP:35357/v2.0 service-create --name keystone --type identity --description "OpenStack Identity"
SERVICE_ID=$(docker exec ${KS_CONT} keystone --os-token $OPENSTACK_ADMIN_TOKEN --os-endpoint http://$CONTROLLER_FIP:35357/v2.0 service-list | awk '/ identity / {print $2}')
docker exec ${KS_CONT} keystone --os-token $OPENSTACK_ADMIN_TOKEN --os-endpoint http://$CONTROLLER_FIP:35357/v2.0 endpoint-create --service-id "${SERVICE_ID}" --publicurl http://$CONTROLLER_FIP:5000/v2.0 --internalurl http://$CONTROLLER_FIP:5000/v2.0 --adminurl http://$CONTROLLER_FIP:35357/v2.0 --region regionOne
