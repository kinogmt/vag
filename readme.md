# vagrant files for Fedora and CentOS

Vagrant file and some scripts to start docker, k8s, nomad and consul
on CentOS or Fedora.
It is supporting only AWS and libvert now.

Note that k8s, nomad and consul are installed and started
only on *CentOS* for now.

## install packages for vagrant and libvirt plugin(kvm/qemu)

```
$ dnf install vagrant vagrant-libvirt
```
  or download vagrant binary from https://www.vagrantup.com/downloads and
```
$ vagrant plugin install vagrant-libvirt
```


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

