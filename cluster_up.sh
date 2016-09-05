REPLICAS=2
OVERLAY_NETWORK=my-cluster-network
REGISTRY_HOST=manager

# Bring up cluster infrastructure
vagrant up manager;vagrant up node_1;vagrant up node_2;

# Deploy service (ruby app) -- Run with replicas to be able to use the scale command
# Redis, Nginx and Interlock containers are run during vagrant provisioning as they don't need the entire infrastructure up
vagrant ssh manager -c "docker service create --constraint 'node.role!=manager' --replicas ${REPLICAS} --network ${OVERLAY_NETWORK} --name my-app ${REGISTRY_HOST}:5000/my-app:1.0"