#! /usr/bin/bash
##title          : config
##description    : Stores configuration information for nova and cinder stateless images
##author         : Abhishek Mukherjee
##email          : abhishek.mukherjee@clustervision.com

# [logging]
LOGFILE=/var/log/postinstall.log

# [openstack controller]
OPENSTACK_CONTROLLER=10.141.255.254

# [rabbitmq]
RPC_PASS=guest

# [nova]
NOVA_PASS=system

# [cinder]
CINDER_PASS=system
CINDER_DBPASS=system
