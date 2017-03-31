#!/bin/sh

PRIMARY_IP=$(hostname -i)
consul agent -data-dir=/tmp/consul -config-dir=/etc/consul.d \
    -bind=${PRIMARY_IP}
