#!/bin/sh

# === Commands for K8S MASTER ==========================
# --- Initialize the cluster
kubeadm reset
systemctl enable --now kubelet
kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all

# --- Configure kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# --- Add hosts or configure master to run pods
# By default, your cluster will not schedule pods on the master
# for security reasons.
# If you want to be able to schedule pods on the master,
# e.g. for a single-machine Kubernetes cluster run:
# ---
kubectl taint nodes --all node-role.kubernetes.io/master-
