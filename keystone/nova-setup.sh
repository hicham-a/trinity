#! /usr/bin/env bash

KS_CONT="keystone"
obol -H ldap://controller -w $LDAP_ADMIN_PW user add nova --password $OPENSTACK_NOVA_PW --cn nova --sn nova --givenName nova
docker exec ${KS_CONT} keystone --os-token $OPENSTACK_ADMIN_TOKEN --os-endpoint http://$CONTROLLER_FIP:35357/v2.0 user-role-add --user nova --tenant service --role admin
docker exec ${KS_CONT} keystone --os-token $OPENSTACK_ADMIN_TOKEN --os-endpoint http://$CONTROLLER_FIP:35357/v2.0 service-create --name nova --type compute --description "OpenStack Compute"
SERVICE_ID=$(docker exec ${KS_CONT} keystone --os-token $OPENSTACK_ADMIN_TOKEN --os-endpoint http://$CONTROLLER_FIP:35357/v2.0 service-list | awk '/ compute / {print $2}')
docker exec ${KS_CONT} keystone --os-token $OPENSTACK_ADMIN_TOKEN --os-endpoint http://$CONTROLLER_FIP:35357/v2.0 endpoint-create --service-id "${SERVICE_ID}" --publicurl http://$CONTROLLER_FIP:8774/v2/%\(tenant_id\)s --internalurl http://$CONTROLLER_FIP:8774/v2/%\(tenant_id\)s --adminurl http://$CONTROLLER_FIP:8774/v2/%\(tenant_id\)s --region regionOne

