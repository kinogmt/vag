#!/bin/sh

# === Commands for K8S (non-master) NODES ==============
# --- join the cluster ---
# IP, TOKEN and HASH should be defined manually using the values
# from kubeadm init command by MASTER
# IP is the IP address of the MASTER
# ---

kubeadm reset
systemctl enable kubelet --now
kubeadm join $IP:6443 --token $TOKEN -discovery-token-ca-cert-hash sha256:$HASH --ignore-preflight-errors=all

