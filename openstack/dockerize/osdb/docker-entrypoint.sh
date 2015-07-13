#!/bin/bash
set -e

mysql_install_db --user=mysql --datadir=/var/lib/mysql
chown -R mysql:mysql /var/lib/mysql

exec "$@"
