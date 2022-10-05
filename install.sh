#!/bin/sh

RELF=/etc/os-release

if [ -f $RELF ]; then
  source $RELF
else
  echo "unknown os"
  exit 1
fi

case $ID in
  "rocky") echo ::: rocky; DNF=dnf; DNFMNG="dnf config-manager";;
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
fi

# --- package based installations for non ostree OS -----------------------------

echo "$VUSER soft nproc 196608" >> /etc/security/limits.d/20-nproc.conf
echo "$VUSER hard nproc 196608" >> /etc/security/limits.d/20-nproc.conf

# --- epel and uis for centos ---
if [ $ID == centos ]; then
  # --- for git 2.x ---
  # following installs ius as well as epel
  $DNF install -y \
    https://repo.ius.io/ius-release-el7.rpm \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  GIT=git224
  DNFOPTS="--enablerepo=ius"
# --- epel for rocky ---
elif [ $ID == rocky ]; then
  $DNF install -y epel-release
  GIT=git
  DNFOPTS="--enablerepo=epel"
else
  GIT=git
  DNFOPTS=""
fi
$DNF install -y $GIT $DNFOPTS

# --- misc -------------------------
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0

echo DOCKER_PKG_REPO: $DOCKER_PKG_REPO
if [ $DOCKER_PKG_REPO == docker.com ]; then
  # --- use docker.com official repo --------
  # -- use "centos" repo for rocky --
  if [ $ID == rocky ]; then
    DCEREPOURL=https://download.docker.com/linux/centos/docker-ce.repo
  else
    DCEREPOURL=https://download.docker.com/linux/${ID}/docker-ce.repo
  fi
  curl -o docker-ce.repo $DCEREPOURL
  $DNFMNG --add-repo docker-ce.repo
  DOCKERPKG=docker-ce
else
  # --- use centos/fedora repo for docker ---
  DOCKERPKG=docker
fi

PKGS="$DOCKERPKG avahi bind-utils emacs-nox unzip rlwrap screen jq \
      openssl-devel curl-devel expat-devel ncurses-devel make gcc"
echo installing $PKGS
$DNF install -y $PKGS

# --- use devicemapper -------------------------
#    disable device mapper
#if [ $DOCKER_PKG_REPO == docker.com ]; then
#  if [ -f /usr/lib/systemd/system/docker.service ]; then
#    sed -ie "s/\(ExecStart.*\)/\1 --storage-driver devicemapper/" /usr/lib/systemd/system/docker.service
#  fi
#fi
# ----------------------------------------------
systemctl start docker
systemctl enable docker
systemctl start avahi-daemon
systemctl enable avahi-daemon

# --- stop unnecessary services ---
systemctl stop postfix || true
systemctl disable postfix || true

if [ $DOCKERPKG == docker ]; then
  DR=dockerroot # old docker such as 1.12
else
  DR=docker     # new docker such as 17.03
fi
groupadd -f $DR
chown root:$DR /var/run/docker.sock
usermod -a -G $DR $ID > /dev/null 2>&1
usermod -a -G $DR vagrant > /dev/null 2>&1

# --- docker compose ---
curl -L https://github.com/docker/compose/releases/download/1.25.5/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

# --- network ---
sysctl -w net.bridge.bridge-nf-call-iptables=1
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv4.conf.all.forwarding=1
sysctl -w net.ipv4.conf.all.route_localnet=1
sudo iptables -P FORWARD ACCEPT

# --- centos only for now ---
if [ $ID == centos ]; then
  if [ ttt$K8S != ttt ]; then
    # --- kubernetese ---
    $DNFMNG --add-repo ${SYNC}/kubernetes.repo
    $DNF install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
    systemctl enable --now kubelet
    if [ $K8S == master ]; then
      # --- init control plain ---
      kubeadm init --pod-network-cidr 10.244.0.0/16
      # --- setup kubeconfig -----
      cp /etc/kubernetes/admin.conf /home/${VUSER}/
      chown ${VUSER}:${VUSER} /home/${VUSER}/admin.conf
      export KUBECONFIG=/home/${VUSER}/admin.conf
      echo "export KUBECONFIG=~/admin.conf" >> /home/${VUSER}/.bashrc
      # --- start flannel --------
      BASE_URL=https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation
      curl -sSL ${BASE_URL}/kube-flannel.yml |  kubectl create -f -
      # remove dedicated taint to put workoer pods on master as well
      kubectl taint nodes --all node-role.kubernetes.io/master-
    fi
  fi

  if [ ttt$NOMAD != ttt ]; then
    # --- consul and nomad ---
    CHECKPOINT_URL="https://checkpoint-api.hashicorp.com/v1/check"
    for COMP in consul nomad; do
      T_VER=$(curl -s "${CHECKPOINT_URL}/${COMP}" | jq .current_version | tr -d '"')
      curl -sSL https://releases.hashicorp.com/${COMP}/${T_VER}/${COMP}_${T_VER}_linux_amd64.zip -o ${COMP}.zip
      unzip ${COMP}.zip
      sudo chmod +x ${COMP}
      sudo mv ${COMP} /usr/bin/
      sudo mkdir -p /etc/${COMP}.d
      sudo chmod a+w /etc/${COMP}.d
    done
  fi
fi


