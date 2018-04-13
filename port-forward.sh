#!/bin/sh
if [ $# -eq 3 ]; then
    if [ $3 != del ]; then
        echo "usage: $0 from-port to-ip:to-port (del)"
        exit 1
    fi
    sudo iptables -D PREROUTING -t nat -p tcp --dport $1 -j DNAT --to $2
    exit 0
fi

if [ $# -eq 2 ]; then
    sudo iptables -I PREROUTING -t nat -p tcp --dport $1 -j DNAT --to $2
    exit 0
fi

echo "usage: $0 from-port to-ip:to-port (del)"
exit 2

