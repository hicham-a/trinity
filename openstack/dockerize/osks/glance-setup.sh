#! /usr/bin/env bash
IP=$(hostname -i)
docker exec osks keystone --os-token system --os-endpoint http://${IP}:35357/v2.0 user-create --name glance --pass system 
docker exec osks keystone --os-token system --os-endpoint http://${IP}:35357/v2.0 user-role-add --user glance --tenant service --role admin
docker exec osks keystone --os-token system --os-endpoint http://${IP}:35357/v2.0 service-create --name glance --type image --description "OpenStack Image Service"
SERVICE_ID=$(docker exec osks keystone --os-token system --os-endpoint http://${IP}:35357/v2.0 service-list | awk '/ image / {print $2}')
docker exec osks keystone --os-token system --os-endpoint http://${IP}:35357/v2.0 endpoint-create --service-id "${SERVICE_ID}" --publicurl http://${IP}:9292/v2.0 --internalurl http://${IP}:9292/v2.0 --adminurl http://${IP}:9292/v2.0 --region regionOne
