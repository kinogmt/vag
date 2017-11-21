#!/bin/sh

IP1=`vagrant ssh v1 -- hostname -i|awk -e '{print $1}'`
IP2=`vagrant ssh v2 -- hostname -i|awk -e '{print $1}'`
IP3=`vagrant ssh v3 -- hostname -i|awk -e '{print $1}'`
IP4=`vagrant ssh v4 -- hostname -i|awk -e '{print $1}'`
IP5=`vagrant ssh v5 -- hostname -i|awk -e '{print $1}'`
IP6=`vagrant ssh v6 -- hostname -i|awk -e '{print $1}'`

echo $IP1  s3-region1.cloudian.com s3-region1.mycloudianhyperstore.com 
echo $IP1  s3-admin.cloudian.com s3-admin.mycloudianhyperstore.com
echo $IP1  cmc.cloudian.com cmc.mycloudianhyperstore.com

echo $IP1 v1.ec2.internal v1
echo $IP2 v1.ec2.internal v2
echo $IP3 v1.ec2.internal v3
echo $IP4 v1.ec2.internal v4
echo $IP5 v1.ec2.internal v5
echo $IP6 v1.ec2.internal v6

echo ==================test.csv

echo region1,v1,$IP1,DC1,RAC1
echo region1,v2,$IP2,DC1,RAC1
echo region1,v3,$IP3,DC1,RAC1
echo region1,v4,$IP4,DC1,RAC1
echo region1,v5,$IP5,DC1,RAC1
echo region1,v6,$IP6,DC1,RAC1

echo ===============dnsmasq.conf

echo address=/.s3-region1.cloudian.com/127.0.0.1
echo address=/s3-region1.cloudian.com/127.0.0.1
echo address=/.s3-website-region1.cloudian.com/127.0.0.1
echo address=/cmc.cloudian.com/127.0.0.1
echo address=/s3-admin.cloudian.com/127.0.0.1
echo address=/v1/$IP1
echo address=/v2/$IP2
echo address=/v3/$IP3
echo address=/v4/$IP4
echo address=/v5/$IP5
echo address=/v6/$IP6

