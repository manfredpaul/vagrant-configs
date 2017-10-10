#!/bin/sh

echo " "
echo "---------------------------------------------------------------------------------------------------------------"
echo "----- updating hosts file"
echo "---------------------------------------------------------------------------------------------------------------"
echo " "

sudo mv /tmp/install/hosts /etc/hosts
sudo chown root:root /etc/hosts

hostname default.hdp.local
sed -i "s/^HOSTNAME=localhost.localdomain/HOSTNAME=default.hdp.local/g" /etc/sysconfig/network

