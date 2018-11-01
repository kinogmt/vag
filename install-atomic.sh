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
fi

# --- repo for CentOS kubeadm ---
if [ $ID == centos ]; then
  cat <<EOF > /etc/yum.repos.d/virt7-kubernetes-110-release.repo
[virt7-kubernetes-110-release]
name=virt7-kubernetes-110-release
baseurl=http://cbs.centos.org/repos/virt7-kubernetes-110-release/x86_64/os
enabled=1
gpgcheck=0
EOF
fi

# --- upgrade first ---
rpm-ostree upgrade

# --- install kubeadm ---
rpm-ostree install kubernetes-kubeadm ethtool crictl

# --- SELinux labelling ---
#  In order to use kubeadm with selinux in enforcing mode,
#  create and set the context of /var/lib/etcd, /etc/kubernetes/pki,
#  and /etc/cni/net.d:
for i in {/var/lib/etcd,/etc/kubernetes/pki,/etc/kubernetes/pki/etcd,/etc/cni/net.d}; do
    mkdir -p $i && chcon -Rt svirt_sandbox_file_t $i;
done

# --- SELInux permissilve mode for now ------------------------
setenforce 0
sed -i s/SELINUX=enforcing/SELINUX=permissive/ /etc/sysconfig/selinux
sed -i s/SELINUX=enforcing/SELINUX=permissive/ /etc/selinux/config
# --- reboot for rpm-ostree -----------------------------------
systemctl reboot

