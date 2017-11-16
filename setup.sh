#!/bin/sh

IP1=`vagrant ssh v1 -- hostname -i|awk -e '{print $1}'`
IP2=`vagrant ssh v2 -- hostname -i|awk -e '{print $1}'`
IP3=`vagrant ssh v3 -- hostname -i|awk -e '{print $1}'`
IP4=`vagrant ssh v4 -- hostname -i|awk -e '{print $1}'`
IP5=`vagrant ssh v5 -- hostname -i|awk -e '{print $1}'`
IP6=`vagrant ssh v6 -- hostname -i|awk -e '{print $1}'`

echo $IP1 s3-region1.mycloudianhyperstore.com
echo $IP1 s3-admin.mycloudianhyperstore.com
echo $IP1 cmc.mycloudianhyperstore.com

echo $IP1 v1
echo $IP2 v2
echo $IP3 v3
echo $IP4 v4
echo $IP5 v5
echo $IP6 v6

echo

echo region1,v1,$IP1,DC1,RAC1
echo region1,v2,$IP2,DC1,RAC1
echo region1,v3,$IP3,DC1,RAC1
echo region1,v4,$IP4,DC1,RAC1
echo region1,v5,$IP5,DC1,RAC1
echo region1,v6,$IP6,DC1,RAC1
