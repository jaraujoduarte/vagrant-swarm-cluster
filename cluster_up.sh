REPLICAS=2
OVERLAY_NETWORK=my-cluster-network
REGISTRY_HOST=manager

# Bring up cluster infrastructure
vagrant up manager;vagrant up node_1;vagrant up node_2;

# Deploy service (ruby app) -- Run with global option to ensure only one task per node
# Redis, Nginx and Interlock containers are run during vagrant provisioning as they don't need the entire infrastructure up
vagrant ssh manager -c "docker service create --constraint 'node.role!=manager' --mode global --network ${OVERLAY_NETWORK} --name my-app ${REGISTRY_HOST}:5000/my-app:1.0"