#!/bin/bash

if [ ! -f /.run-rabbitmq-server-firstrun ]; then
	# TBD
	# PASS=`pwgen -s 12 1`
#	PASS=guest
#        USER=guest
#	cat >/etc/rabbitmq/rabbitmq.config <<EOF
#[
#	{rabbit, [{default_user, <<"$USER">>}, {default_pass, <<"$PASS">>}]}
#].
#EOF

	# echo "set default user = admin and default password = $PASS"

	# add the vhost
	# (sleep 10 && rabbitmqctl add_vhost $DEVEL_VHOST_NAME && rabbitmqctl set_permissions -p $DEVEL_VHOST_NAME admin ".*" ".*" ".*") &

	cat >/etc/rabbitmq/rabbitmq.config <<EOF
[{rabbit, [{loopback_users, []}]}].
EOF
	touch /.run-rabbitmq-server-firstrun
fi

exec /usr/sbin/rabbitmq-server
