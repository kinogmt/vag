# -*- mode: ruby -*-
# vi: set ft=ruby :

# ----------------------------
def envd(name, default)
  case ENV[name]
    when nil then
      default
    else
      ENV[name]
  end
end

# --- configuration paramters -------------------------
OS = envd("VAG_OS", "centos")

AMIFEDORA = envd("AWS_AMI_FEDORA", "ami-e754e298") # fedora 28/us-east-1
AMICENTOS = envd("AWS_AMI_CENTOS", "ami-9887c6e7") # centos 7.5/us-east-1
AMIFEDORAATOMIC = envd("AWS_AMI_FEDORA_ATOMIC", "ami-095734cd6327f5b58") # fedora atomic 28/us-east-1
AMICENTOSATOMIC = envd("AWS_AMI_CENTOS_ATOMIC", "ami-3bf1b444") # centos atomic 7/us-east-1
AWSRG = envd("AWS_RG", "us-east-1")         # AWS region
AWSSG = envd("AWS_SG", "sg-5389a22d")       # AWS security group/us-east-1
AWSSN = envd("AWS_SN", "subnet-407eb41a")   # AWS subnet/us-east-1
AWSIT = envd("AWS_IT", "m4.4xlarge")

AKEY = envd("AWS_ACCESS_KEY_ID", "none")
SKEY = envd("AWS_SECRET_ACCESS_KEY", "none")
KEYPAIR = envd("AWS_KEYPAIR_NAME", "none")
KEYPATH = envd("AWS_KEY_PATH", "~/.ssh/aws_ssh_key")

DOCKER_PKG_REPO = envd("DOCKER_PKG_REPO", "docker.com")
# docker.com: docker.com repository
# os:         OS repository

K8S = envd("K8S", "")
NOMAD = envd("NOMAD", "")

#puts "os: " + OS
case OS
  when "fedora-atomic" then
    LIBVIRTBOX = "fedora/28-atomic-host"
    AMI = AMIFEDORAATOMIC
    AWSUSER = "fedora"
    INSTALL = envd("INST", "install-atomic.sh")
  when "fedora" then
    LIBVIRTBOX = "fedora/28-cloud-base"
    AMI = AMIFEDORA
    AWSUSER = "fedora"
    INSTALL = envd("INST", "install.sh")
  when "centos-atomic" then
    LIBVIRTBOX = "centos/atomic-host"
    AMI = AMICENTOSATOMIC
    AWSUSER = "centos"
    SYNC = "/home/centos/sync"
    INSTALL = envd("INST", "install-atomic.sh")
  when "centos" then
    LIBVIRTBOX = "centos/7"
    AMI = AMICENTOS
    AWSUSER = "centos"
    INSTALL = envd("INST", "install.sh")
  else
    puts "invalid OS name:" + OS + ":"
end
#puts "aws ssh user: " + AWSUSER

# -----------------------------------------------------
Vagrant.configure(2) do |config|
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # --- use fixed uuid for "v1" only ---
  config.vm.define "v1" do |node|
      node.vm.provider :libvirt do |libvirt|
        libvirt.uuid = 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA'
      end
  end

  (1..6).each do |i|
    config.vm.define "v#{i}" do |node|
      node.vm.provision :shell, inline: "hostname v#{i}"
      node.vm.provision :shell, inline: "echo v#{i} > /etc/hostname"
      node.vm.provision "shell", path: INSTALL, env: {"DOCKER_PKG_REPO" => DOCKER_PKG_REPO, "K8S" => K8S, "NOMAD" => NOMAD}
      # --- port forwarding for virtualbox --------------------
      node.vm.network "forwarded_port", guest: 22, host: 7221+i, id: "ssh"
      node.vm.network "forwarded_port", guest: 8443, host: 18442+i, id: "https"
    end
  end

  config.vm.provider "virtualbox" do |v, override|
    override.vm.box = LIBVIRTBOX
    override.vm.synced_folder ".", "/home/vagrant/sync", type: "rsync"
    v.cpus = 2
    v.memory = 8192
  end 


  config.vm.provider :libvirt do |libvirt, override|
    override.vm.box = LIBVIRTBOX
    override.vm.synced_folder ".", "/home/vagrant/sync", type: "rsync"
    #libvirt.uuid = 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA'
    libvirt.cpus = 4
    libvirt.memory = 32768
    libvirt.machine_virtual_size = 70 # 70GB
  end

  config.vm.provider :aws do |aws, override|
    override.nfs.functional = false
    override.vm.synced_folder ".", "/home/" + AWSUSER + "/sync", type: "rsync"
    override.vm.box = "dummy"
    override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
    override.ssh.username = AWSUSER
    override.ssh.private_key_path = KEYPATH

    aws.region_config AWSRG do |region|
      region.spot_instance = true
      region.spot_max_price = "0.8"
    end

    aws.region = AWSRG
    aws.access_key_id = AKEY
    aws.secret_access_key = SKEY
    aws.keypair_name = KEYPAIR
    aws.ami = AMI
    aws.instance_type = AWSIT

    aws.block_device_mapping = [{ "DeviceName" => "/dev/sda1", "Ebs.VolumeType" => "gp2", "Ebs.VolumeSize" => 70 }] # 70GB

    aws.security_groups = [AWSSG]
    aws.subnet_id = AWSSN
    aws.associate_public_ip = true
    aws.elastic_ip = false
    aws.user_data =<<USER_DATA
#!/bin/sh
sed -i -e "s/^\\(Defaults.*requiretty\\)/#\\1/" /etc/sudoers
USER_DATA
  end
end
