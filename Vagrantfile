$swarm_manager_ip = "10.0.0.2"
$swarm_manager_hostname = "manager"
$docker_registry = "manager"

# Script automatically enter swarm mode on the manager and makes the token available
$swarm_init_script = <<SCRIPT
docker swarm init --advertise-addr #{$swarm_manager_ip}
docker swarm join-token worker -q > /vagrant/swarm.token
docker network create --driver overlay --subnet 10.0.9.0/24 --opt encrypted my-cluster-net
SCRIPT

# Build and push in advance so it's accesible via the registry on the manager node
$build_push_app = <<SCRIPT
# Build docker image for the ruby app and publish to registry
docker build -t my-app:latest /vagrant/app/
docker tag my-app:latest #{$docker_registry}:5000/my-app:latest
docker push #{$docker_registry}:5000/my-app:latest
SCRIPT

# Script to access to registry -- Registry needed to be able to use docker-compose/swarm for scaling
$insecure_registry_opt = <<-SCRIPT
if ! grep -q "insecure-registry" /etc/default/docker; then
    echo 'DOCKER_OPTS="--insecure-registry #{$docker_registry}:5000"' >> /etc/default/docker
	sudo service docker restart
fi
SCRIPT

# Add manager as known hostname
$manager_hostname = <<-SCRIPT
if ! grep -q "#{$swarm_manager_ip} manager" /etc/hosts; then
    echo '#{$swarm_manager_ip} manager' >> /etc/hosts
fi
SCRIPT

# Uses the obtained token to join the swarm
def build_swarm_join_string()
	token_file = File.open("swarm.token", "rb")
	swarm_join_string = "docker swarm join --token #{token_file.read.strip} #{$swarm_manager_hostname}:2377"
end

Vagrant.configure("2") do |config|
	config.vm.box = "phusion/ubuntu-14.04-amd64"
	config.vm.box_check_update = false

	config.vm.define "manager" do |manager|
	    manager.vm.hostname = "manager"
		manager.vm.network "private_network", ip: $swarm_manager_ip, virtualbox__intnet: true

		manager.vm.provision "docker" do |d|
			d.pull_images "registry:2"
			d.run "registry:2", args: "-p 5000:5000 --name registry"
		end

		manager.vm.provision "shell", inline: $insecure_registry_opt
		manager.vm.provision "shell", inline: $swarm_init_script
		manager.vm.provision "shell", inline: $build_push_app
	end

	config.vm.define "node_1" do |node_1|
		node_1.vm.hostname = "node-1"
		node_1.vm.network "private_network", ip: "10.0.0.3", virtualbox__intnet: true

		node_1.vm.provision "docker"
		node_1.vm.provision "shell", inline: $insecure_registry_opt
		node_1.vm.provision "shell", inline: $manager_hostname
		node_1.vm.provision "shell", inline: build_swarm_join_string
	end

	config.vm.define "node_2" do |node_2|
		node_2.vm.hostname = "node-2"
		node_2.vm.network "private_network", ip: "10.0.0.4", virtualbox__intnet: true

		node_2.vm.provision "docker"
		node_2.vm.provision "shell", inline: $insecure_registry_opt
		node_2.vm.provision "shell", inline: $manager_hostname
		node_2.vm.provision "shell", inline: build_swarm_join_string
	end
end