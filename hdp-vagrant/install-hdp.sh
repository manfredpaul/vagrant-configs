#!/bin/sh

echo " "
echo "---------------------------------------------------------------------------------------------------------------"
echo "----- sleep before calling ambari REST apis"
echo "---------------------------------------------------------------------------------------------------------------"
echo " "

curl --silent --show-error -H "X-Requested-By: ambari" -X POST -d '@/tmp/install/blueprint.json' -u admin:admin http://default.hdp.local:8080/api/v1/blueprints/generated
curl --silent --show-error -H "X-Requested-By: ambari" -X PUT -d '@/tmp/install/create-hdp-repo.json' -u admin:admin  http://default.hdp.local:8080/api/v1/stacks/HDP/versions/2.2/operating_systems/redhat6/repositories/HDP-2.2
curl --silent --show-error -H "X-Requested-By: ambari" -X PUT -d '@/tmp/install/create-hdp-utils-repo.json' -u admin:admin  http://default.hdp.local:8080/api/v1/stacks/HDP/versions/2.2/operating_systems/redhat6/repositories/HDP-UTILS-1.1.0.20 
curl --silent --show-error -H "X-Requested-By: ambari" -X POST -d '@/tmp/install/create-cluster.json' -u admin:admin http://default.hdp.local:8080/api/v1/clusters/default

echo " "
echo "---------------------------------------------------------------------------------------------------------------"
echo "----- sleep before checking progress"
echo "---------------------------------------------------------------------------------------------------------------"
echo " "

sleep 30

echo " "
echo "---------------------------------------------------------------------------------------------------------------"
echo "----- checking progress"
echo "---------------------------------------------------------------------------------------------------------------"
echo " "

PROGRESS=0
until [ $PROGRESS -eq 100 ]; do
    PROGRESS=`curl --silent --show-error -H "X-Requested-By: ambari" -X GET -u admin:admin http://default.hdp.local:8080/api/v1/clusters/default/requests/1 2>&1 | grep -oP '\"progress_percent\"\s+\:\s+\K[0-9]+'`
    TIMESTAMP=$(date "+%m/%d/%y %H:%M:%S")
    echo -ne "$TIMESTAMP - $PROGRESS percent complete!"\\r
    sleep 60
done

echo " "
echo "---------------------------------------------------------------------------------------------------------------"
echo "----- adding users"
echo "---------------------------------------------------------------------------------------------------------------"
echo " "

useradd -G hdfs admin
usermod -a -G users admin
usermod -a -G hadoop admin
usermod -a -G hive admin

usermod -a -G users vagrant
usermod -a -G hdfs vagrant
usermod -a -G hadoop vagrant
usermod -a -G hive vagrant

echo " "
echo "---------------------------------------------------------------------------------------------------------------"
echo "----- doing some hdfs view stuff"
echo "---------------------------------------------------------------------------------------------------------------"
echo " "

sudo su - hdfs << EOF
    hadoop fs -mkdir /user/admin
    hadoop fs -chown admin:hadoop /user/admin
EOF
