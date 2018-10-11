#!/bin/sh

RELF=/etc/os-release

if [ -f $RELF ]; then
  source $RELF
else
  echo "unknown os"
  exit 1
fi

if [ -d /home/vagrant ]; then
  VUSER=vagrant
else
  VUSER=$ID
fi

# --- sync files ---
SYNC=/home/${VUSER}/sync
if [ -d ${SYNC}/home ]; then
  su ${VUSER} -c "cp -R ${SYNC}/home/. /home/${VUSER}/"
  mkdir -p /root/.ssh/
  cp /home/${VUSER}/.ssh/* /root/.ssh/
  chown root:${VUSER} /var/run/docker.sock
fi

# --- repo for CentOS kubeadm ---
if [ $ID == centos ]; then
  cat <<EOF > /etc/yum.repos.d/virt7-kubernetes-110-candidate.repo
[virt7-kubernetes-110-candidate]
name=virt7-kubernetes-110-candidate
baseurl=http://cbs.centos.org/repos/virt7-kubernetes-110-candidate/x86_64/os
enabled=1
gpgcheck=0
EOF
fi

# --- upgrade first ---
rpm-ostree upgrade

# --- install kubeadm ---
rpm-ostree install kubernetes-kubeadm

# --- SELinux labelling ---
#  In order to use kubeadm with selinux in enforcing mode,
#  create and set the context of /var/lib/etcd, /etc/kubernetes/pki,
#  and /etc/cni/net.d:
for i in {/var/lib/etcd,/etc/kubernetes/pki,/etc/kubernetes/pki/etcd,/etc/cni/net.d}; do
    mkdir -p $i && chcon -Rt svirt_sandbox_file_t $i;
done

# --- reboot for rpm-ostree -----------------------------------
systemctl reboot

#########################################################################
# Commands hereafter need to be run manually because of the reboot above.
#########################################################################




# === Commands after reboot for K8S MASTER ==========================
# --- Initialize the cluster
#kubeadm reset
#systemctl enable --now kubelet
#kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all

# --- Configure kubectl
#mkdir -p $HOME/.kube
#sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#sudo chown $(id -u):$(id -g) $HOME/.kube/config

# --- Add hosts or configure master to run pods
# By default, your cluster will not schedule pods on the master
# for security reasons.
# If you want to be able to schedule pods on the master,
# e.g. for a single-machine Kubernetes cluster run:
# ---
#kubectl taint nodes --all node-role.kubernetes.io/master-


# === Commands after reboot for K8S (non-master) NODES ==============
# --- join the cluster ---
# IP, TOKEN and HASH should be defined manually using the values
# from kubeadm init command by MASTER
# IP is the IP address of the MASTER
# ---

#kubeadm reset
#systemctl enable kubelet --now
#kubeadm join $IP:6443 --token $TOKEN -discovery-token-ca-cert-hash sha256:$HASH --ignore-preflight-errors=all

