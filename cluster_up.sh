REPLICAS=2
OVERLAY_NETWORK=my-cluster-network
REGISTRY_HOST=manager

# Bring up cluster infrastructure
vagrant up manager;vagrant up node_1;vagrant up node_2;

# The virtual ip of the redis container is used as a workaround for a DNS issue whenever a redis consuming services
# After scaling down and back up, the application container would not resolve the redis domain name
REDIS_VIP=$(<./virtual_ip_redis.output);

# Deploy service (ruby app) -- Run with replicas to be able to use the scale command
# Redis, Nginx and Interlock containers are run during vagrant provisioning as they don't need the entire infrastructure up
vagrant ssh manager -c "docker service create --constraint 'node.role!=manager' --env 'redis_ip=${REDIS_VIP}' --replicas ${REPLICAS} --network ${OVERLAY_NETWORK} --name my-app ${REGISTRY_HOST}:5000/my-app:1.0"