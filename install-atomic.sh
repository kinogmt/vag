#!/bin/sh

RELF=/etc/os-release

if [ -f $RELF ]; then
  source $RELF
else
  echo "unknown os"
  exit 1
fi

case $ID in
  "centos") echo ::: centos; DNF=yum; DNFMNG=yum-config-manager;;
  "fedora") echo ::: fedora; DNF=dnf; DNFMNG="dnf config-manager";;
esac

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

# --- repo for kubeadm ---
cat <<EOF > /etc/yum.repos.d/virt7-kubernetes-110-candidate.repo
[virt7-kubernetes-110-candidate]
name=virt7-kubernetes-110-candidate
baseurl=http://cbs.centos.org/repos/virt7-kubernetes-110-candidate/x86_64/os
enabled=1
gpgcheck=0
EOF

# --- install k8s-node, k8s-client and k8s-kubeadm ---
rpm-ostree install kubernetes-node kubernetes-client kubernetes-kubeadm

# --- reboot for rpm-ostree -----------------------------------
systemctl reboot
