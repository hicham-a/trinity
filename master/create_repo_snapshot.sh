#!/bin/bash
set -x
DATE=$(date +%Y%m%d)
mkdir -p /install/post/$DATE/centos7.0/x86_64
if [ -d /install/post/otherpkgs/centos7.0/x86_64/ ]; then
	cp -rl /install/post/otherpkgs/centos7.0/x86_64/* /install/post/$DATE/centos7.0/x86_64
        rm /install/post/otherpkgs
fi
reposync -n -r epel -r extras -r updates -r xcat-2-core -r xcat-dep -r openstack-juno -p /install/post/$DATE/centos7.0/x86_64/
ln -sT /install/post/$DATE /install/post/otherpkgs
createrepo /install/post/otherpkgs/centos7.0/x86_64/


