#!/bin/bash
set -x

mysql_install_db --user=mysql --datadir=/var/lib/mysql
chown -R mysql:mysql /var/lib/mysql
cat > /etc/my.cnf.d/dbinit.cnf <<-EOF
[mysqld]
init-file=/tmp/dbinit.sql
EOF
exec "$@"
