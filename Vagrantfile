$swarm_manager_ip = "10.0.0.2"
$swarm_manager_hostname = "manager"
$docker_registry = "manager"
$overlay_network = "my-cluster-network"
$proxy_port = "9999"
$host_port = "9999"

# Script automatically enter swarm mode on the manager and makes the token available
$swarm_init_script = <<SCRIPT
docker swarm init --advertise-addr #{$swarm_manager_ip}
docker swarm join-token worker -q > /vagrant/swarm.token
docker network create --driver overlay --subnet 10.0.9.0/24 --opt encrypted #{$overlay_network}
SCRIPT

# Useful to test the swarm provided DNS
$create_busybox_service = <<SCRIPT
docker service create --constraint "node.role==manager" --replicas 1 --network #{$overlay_network} --name my-busybox busybox sleep 3000
SCRIPT

$create_proxy_service = <<SCRIPT
docker service create --constraint 'node.role==manager' --replicas 1 --network my-cluster-network \
--mount type=bind,dst=/etc/nginx/conf.d/default.conf,src=/vagrant/proxy/default.conf -p #{$proxy_port}:80 --name my-proxy nginx
SCRIPT

# Pull redis image and start the backend container
$create_redis_service = <<SCRIPT
docker service create --constraint "node.role==manager" --replicas 1 --network #{$overlay_network} --name my-redis redis:alpine
SCRIPT

# Build and push in advance so it's accesible via the registry on the manager node
$build_push_app = <<SCRIPT
docker build -t my-app:1.0 /vagrant/app/
docker tag my-app:1.0 #{$docker_registry}:5000/my-app:1.0
docker push #{$docker_registry}:5000/my-app:1.0
SCRIPT

# Access to insecure registry
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
	config.vm.box = "ubuntu/trusty64"
	config.vm.box_check_update = false
	config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

	config.vm.define "manager" do |manager|
	    manager.vm.hostname = "manager"
		manager.vm.network "private_network", ip: $swarm_manager_ip, virtualbox__intnet: true
		manager.vm.network "forwarded_port", guest: $proxy_port, host: $host_port

		manager.vm.provision "docker" do |d|
			d.pull_images "registry:2"
			d.run "registry:2", args: "-p 5000:5000 --name registry"
		end

		manager.vm.provision "shell", inline: $insecure_registry_opt
		manager.vm.provision "shell", inline: $swarm_init_script
		manager.vm.provision "shell", inline: $build_push_app
		manager.vm.provision "shell", inline: $create_redis_service
		manager.vm.provision "shell", inline: $create_proxy_service
		manager.vm.provision "shell", inline: $create_busybox_service
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