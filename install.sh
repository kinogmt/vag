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

# --- epel for centos ---
if [ $ID == centos ]; then
  rpm -ivh https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm
fi

# --- misc -------------------------
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce Permissive

su $ID -c "cp /vagrant/screenrc /home/$ID/.screenrc"

# --- docker engine and other packages ---
$DNFMNG \
    --add-repo \
    https://docs.docker.com/engine/installation/linux/repo_files/$ID/docker.repo
$DNF install -y docker-engine git avahi bind-utils emacs-nox unzip rlwrap screen
systemctl start docker
systemctl enable docker
systemctl start avahi-daemon
systemctl enable avahi-daemon
usermod -a -G docker $ID > /dev/null 2>&1
usermod -a -G docker vagrant > /dev/null 2>&1

# --- docker compose ---
curl -L https://github.com/docker/compose/releases/download/1.11.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

