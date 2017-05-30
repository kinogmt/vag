# vagrant files for Fedora and CentOS

## install packages for vagrant and libvirt plugin(kvm/qemu)

```
$ dnf install vagrant vagrant-libvirt
```


## install pcakges for aws plugin

```
$ dnf install ruby-devel libffi-devel redhat-rpm-config libvirt-devel
$ vagrant plugin install vagrant-aws
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
| VAG_OS                | centos or fedora     | centos             |
| AWS_ACCESS_KEY_ID     | aws access key       | none               |
| AWS_SECRET_ACCESS_KEY | aws secret key       | none               |
| AWS_KEYPAIR_NAME      | aws key pair name    | none               |
| AWS_KEY_PATH          | aws key path         | ~/.ssh/aws_ssh_key |
| AWS_AMI_FEDORA        | aws ami for fedora   | ami-e5ad85f2       |
| AWS_AMI_CENTOS        | aws ami for centos   | ami-46c1b650       |
| AWS_SG                | aws secrity group    | sg-5389a22d        |
| AWS_SN                | aws subnet           | subnet-407eb41a    |
| AWS_IT                | aws instance type    | m4.2xlarge         |
| DOCKER_PKG_REPO       | os or docker.com(*1) | os                 |
```

(\*1) Value "os" uses default repository of OS(cetnos or fedora).
Value "docker.com" uses repository of docker.com to install Docker Engine.

