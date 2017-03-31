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

# --- epel for centos ---
if [ $ID == centos ]; then
  rpm -ivh https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm
fi

# --- misc -------------------------
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce Permissive

if [ -d /vagrant/home ]; then
  su ${VUSER} -c "cp -R /vagrant/home/. /home/${VUSER}/"
fi

# --- docker engine and other packages ---
curl -o docker-ce.repo https://download.docker.com/linux/${ID}/docker-ce.repo
$DNFMNG --add-repo docker-ce.repo
$DNF install -y docker-ce git avahi bind-utils emacs-nox unzip rlwrap screen jq
systemctl start docker
systemctl enable docker
systemctl start avahi-daemon
systemctl enable avahi-daemon
usermod -a -G docker $ID > /dev/null 2>&1
usermod -a -G docker vagrant > /dev/null 2>&1

# --- docker compose ---
curl -L https://github.com/docker/compose/releases/download/1.11.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# --- kubernetese --- centos only for now
if [ $ID == centos ]; then
  cp /vagrant/kubernetes.repo /etc/yum.repos.d/kubernetes.repo
  yum install -y kubelet kubeadm kubectl kubernetes-cni
  systemctl enable kubelet && systemctl start kubelet
fi

# --- consul and nomad ---
CHECKPOINT_URL="https://checkpoint-api.hashicorp.com/v1/check"
CONSUL_VER=$(curl -s "${CHECKPOINT_URL}"/consul | jq .current_version | tr -d '"')
NOMAD_VER=$(curl -s "${CHECKPOINT_URL}"/nomad | jq .current_version | tr -d '"')

curl -sSL https://releases.hashicorp.com/consul/${CONSUL_VER}/consul_${CONSUL_VER}_linux_amd64.zip -o consul.zip
curl -sSL https://releases.hashicorp.com/nomad/${NOMAD_VER}/nomad_${NOMAD_VER}_linux_amd64.zip -o nomad.zip
unzip consul.zip
unzip nomad.zip
sudo chmod +x consul
sudo chmod +x nomad
sudo mv consul /usr/bin/
sudo mv nomad /usr/bin/
sudo mkdir -p /etc/nomad.d
sudo chmod a+w /etc/nomad.d


# --- network ---
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv4.conf.all.forwarding=1
sysctl -w net.ipv4.conf.all.route_localnet=1
sudo iptables -P FORWARD ACCEPT
