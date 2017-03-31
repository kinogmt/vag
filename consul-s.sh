#!/bin/sh

PRIMARY_IP=$(hostname -i)
consul agent -server -bootstrap-expect=1 \
    -data-dir=/tmp/consul -config-dir=/etc/consul.d \
    -bind=${PRIMARY_IP} -ui
