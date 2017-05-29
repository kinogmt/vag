# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  (1..3).each do |i|
    config.vm.define "v#{i}" do |node|
      node.vm.provision :shell, inline: "hostname v#{i}"
      node.vm.provision :shell, inline: "echo v#{i} > /etc/hostname"
      node.vm.provision "shell", path: "install.sh"
    end
  end

  config.vm.provider :libvirt do |libvirt, override|
    case ENV['VAG_OS']
      when 'fedora' then
        override.vm.box = "fedora/25-cloud-base"
      else
        override.vm.box = "centos/7"
    end

    libvirt.cpus = 4
    libvirt.memory = 32768
    libvirt.machine_virtual_size = 50 # 50GB
  end

  config.vm.provider :aws do |aws, override|
    override.nfs.functional = false
    override.vm.box = "dummy"
    override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
    case ENV['VAG_OS']
      when 'fedora' then
        override.ssh.username = "fedora"
      else
        override.ssh.username = "centos"
    end
    override.ssh.private_key_path = "/home/kino/.ssh/kino_aws.pem"

    aws.access_key_id = ENV['AWS_ACCESS_KEY_ID']
    aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    aws.keypair_name = ENV['AWS_KEYPAIR_NAME']

    case ENV['VAG_OS']
      when 'fedora' then
        aws.ami = "ami-e5ad85f2" # fedora 25
      else
        aws.ami = "ami-46c1b650" # centos 7.3
    end

    case ENV['VAG_AWS_IT']
      when nil then
        aws.instance_type = "m4.2xlarge"
     else
        aws.instance_type = ENV['VAG_AWS_IT']
    end

    aws.block_device_mapping = [{ 'DeviceName' => '/dev/sda1', 'Ebs.VolumeSize' => 50 }] # 50GB

    aws.security_groups = ["sg-9e2672e4"]
    aws.subnet_id = "subnet-fa05f38d"
    aws.associate_public_ip = true
    aws.elastic_ip = false
    aws.user_data =<<USER_DATA
#!/bin/sh
sed -i -e 's/^\\(Defaults.*requiretty\\)/#\\1/' /etc/sudoers
USER_DATA
  end
end
