# -*- mode: ruby -*-
# vi: set ft=ruby

Vagrant.configure("2") do |config|

	# Set our operating system
	config.vm.box = "ubuntu/trusty64"

	config.vm.provider "virtualbox" do |v|
  		v.memory = 512
  		v.cpus = 1
	end

	# Configure our provisioner script
	config.vm.synced_folder 'ops/provisioner', '/tmp/provisioner'
	config.vm.provision :opsworks, type: 'shell' do |shell|
		shell.inline = 'if [ ! -f /usr/bin/docker ]; then apt-get update; apt-get -y install linux-image-extra-$(uname -r); modprobe aufs; wget -qO- https://get.docker.com/ | sh; fi; /bin/bash /tmp/provisioner/opsworks "$@"'
	end

	# Define our app layer
	config.vm.define "docker-opswork" do |layer|
		layer.vm.provision :opsworks, type:"shell", args:[
			'ops/dna/stack.json',
			'ops/dna/app.json'
		]

		# Forward port 80 so we can see our work
		layer.vm.network "forwarded_port", guest: 80, host: 8080
		layer.vm.network "private_network", ip: "10.10.10.10"
	end
end
