# vagrant files for Fedora and CentOS

## install packages for vagrant and libvirt plugin(kvm/qemu)

$ dnf install vagrant vagrant-libvirt


## install pcakges for aws plugin

$ dnf install ruby-devel libffi-devel redhat-rpm-config libvirt-devel
$ vagrant plugin install vagrant-aws

## start centos on libvirt

$ vagrant up v1

## start fedora on libvirt

$ VAG_OS=fedora vagrant up v1

## setup AWS keys
$ export AWS_ACCESS_KEY_ID="your-akey"
$ export AWS_SECRET_ACCESS_KEY="your-skey"
$ export AWS_KEYPAIR_NAME="your-keypair-name"


## start centos on aws

$ vagrant up --provider=aws v1

## start fedora on aws

$ VAG_OS=fedora vagrant up --provider=aws v1

