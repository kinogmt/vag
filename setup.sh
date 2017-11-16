#!/bin/sh

IP1=`vagrant ssh v1 -- hostname -i|awk -e '{print $1}'`
IP2=`vagrant ssh v2 -- hostname -i|awk -e '{print $1}'`
IP3=`vagrant ssh v3 -- hostname -i|awk -e '{print $1}'`

echo $IP1 s3-region1.mycloudianhyperstore.com
echo $IP1 s3-admin.mycloudianhyperstore.com
echo $IP1 cmc.mycloudianhyperstore.com

echo $IP1 v1
echo $IP2 v2
echo $IP3 v3

echo

echo region1,v1,$IP1,DC1,RAC1
echo region1,v2,$IP2,DC1,RAC1
echo region1,v3,$IP3,DC1,RAC1
