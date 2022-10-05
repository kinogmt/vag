# vagrant files for Fedora and CentOS

Vagrant file and some scripts to start docker, k8s, nomad and consul
on CentOS or Fedora.
It is supporting only AWS and libvert now.

Note that k8s, nomad and consul are installed and started
only on *CentOS* for now.

NOTE:
vagrant-aws-mkubenka does not work with vagrant 2.2.19.
If you use vagrant-libvirt on 2.2.19(or later?),
do not install vagrant-aws-mkubenka.


## install packages for vagrant

```
$ dnf install vagrant
```
  or download vagrant CentOS RPM package from https://www.vagrantup.com/downloads.

## install pcakges for aws plugin

```
$ dnf install ruby-devel libffi-devel redhat-rpm-config libvirt-devel
```

```
$ vagrant plugin install vagrant-aws
```
  or(for spot instance support)
```
$ vagrant plugin uninstall vagrant-aws
$ vagrant plugin install vagrant-aws-mkubenka --plugin-version "0.7.2.pre.24"
```

Note: For spot instance, 
"Auto-assign public IPv4" for AWS VPC subnet needs to be set to yes.

## install libvirt plugin(kvm/qemu)

```
$ dnf install vagrant-libvirt
```
  or 
```
$ vagrant plugin install vagrant-libvirt
```


## start centos on libvirt

```
$ vagrant up v1
```

## start fedora on libvirt

```
$ VAG_OS=fedora vagrant up v1
```

## setup AWS keys

```
$ export AWS_ACCESS_KEY_ID="your-akey"
$ export AWS_SECRET_ACCESS_KEY="your-skey"
$ export AWS_KEYPAIR_NAME="your-keypair-name"
```


## start centos on aws

```
$ vagrant up --provider=aws v1
```

## start fedora on aws

```
$ VAG_OS=fedora vagrant up --provider=aws v1
```

## start centos on virtualbox

```
$ vagrant up --provider=virtualbox v1
```

## start fedora on virtualbox

```
$ VAG_OS=fedora vagrant up --provider=virtualbox v1
```

## ssh to centos
```
$  vagrant ssh v1
```

## ssh to fedora
```
$ VAG_OS=fedora vagrant ssh v1
```

## environment variables

```
| variable              | value                | default            |
| --------------------- | -------------------- | ------------------ |
| VAG_OS                | centos, fedora, fedora-atomic, centos-atomic | centos             |
| AWS_ACCESS_KEY_ID     | aws access key       | none               |
| AWS_SECRET_ACCESS_KEY | aws secret key       | none               |
| AWS_KEYPAIR_NAME      | aws key pair name    | none               |
| AWS_KEY_PATH          | aws key path         | ~/.ssh/aws_ssh_key |
| AWS_AMI_FEDORA        | aws ami for fedora   | ami-e5ad85f2       |
| AWS_AMI_CENTOS        | aws ami for centos   | ami-46c1b650       |
| AWS_RG                | aws region           | us-east-1          |
| AWS_SG                | aws secrity group    | sg-5389a22d        |
| AWS_SN                | aws subnet           | subnet-407eb41a    |
| AWS_IT                | aws instance type    | m4.2xlarge         |
| DOCKER_PKG_REPO       | os or docker.com(*1) | docker.com         |
```

(\*1) Value "os" uses default repository of OS(cetnos or fedora).
Value "docker.com" uses repository of docker.com to install Docker Engine.

## disk resizing for VirtualBox

In order to resize disk spaze for VirtualBox provider,
it needs following option to enable experimental feature of Vagrant.

```
export VAGRANT_EXPERIMENTAL="disks"
```

An example line for Vagrantfile:
```
   config.vm.provider "virtualbox" do |v, override|
     override.vm.box = LIBVIRTBOX
     override.vm.synced_folder ".", "/home/vagrant/sync", type: "rsync"
     # export VAGRANT_EXPERIMENTAL="disks" is necessary for following disk options
     override.vm.disk :disk, size: "50GB", primary: true
```

With these setup, Vagrant resize the primary disk device to 50GB.
However it does *not* resize partitions of the device.
It will need to run fdisk, partprobe and xfs_growfs commands(see example below).


Example:
```
[root@v2 ~]# fdisk /dev/sda

Welcome to fdisk (util-linux 2.32.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): p
Disk /dev/sda: 5 GiB, 5368709120 bytes, 10485760 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x2470bdf8

Device     Boot Start      End  Sectors Size Id Type
/dev/sda1  *     2048 10485759 10483712   5G 83 Linux

Command (m for help): d
Selected partition 1
Partition 1 has been deleted.

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1): 
First sector (2048-10485759, default 2048): 
Last sector, +sectors or +size{K,M,G,T,P} (2048-10485759, default 10485759): 

Created a new partition 1 of type 'Linux' and of size 5 GiB.
Partition #1 contains a xfs signature.

Do you want to remove the signature? [Y]es/[N]o: n

Command (m for help): w

The partition table has been altered.
Syncing disks.

[root@v2 ~]# partprobe /dev/sda
[root@v2 ~]# xfs_growfs /dev/sda1
meta-data=/dev/sda1              isize=512    agcount=4, agsize=327616 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=1, rmapbt=0
         =                       reflink=1
data     =                       bsize=4096   blocks=1310464, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 1310464 to 13106944
```
