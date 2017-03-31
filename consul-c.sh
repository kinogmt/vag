#!/bin/sh

PRIMARY_IP=$(hostname -i)
consul agent -data-dir=/etc/consul.d/data -config-dir=/etc/consul.d \
    -bind=${PRIMARY_IP}
