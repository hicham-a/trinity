#!/bin/bash

echo "updating master from source code repository"
HERE="`( cd \"$(dirname "$0")" && pwd )`"
cp -Lrv $HERE/rootimg/* /

(git branch | grep "*"; git rev-parse --short HEAD) > /trinity/version
cp /trinity/version /trinity/controller/rootimg/install/postscripts/cv_trinity_version

exit 1

source /etc/profile.d/xcat.sh
mkdir -p /tmp/xcattables
read ETH1 ETH2 ETH3 <<<$(ls /sys/class/net/ | grep "^e" | sort | head -3)
for table in $(ls $HERE/tables); do
    sed -e "s/\<eno1\>/$ETH1/g" -e "s/\<eno2\>/$ETH2/g"  -e "s/\<eno3\>/$ETH3/g" $HERE/tables/$table > /tmp/xcattables/$table;
done

restorexCATdb -Vp /tmp/xcattables  
