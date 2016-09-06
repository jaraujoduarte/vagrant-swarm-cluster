REPLICAS=$1

vagrant ssh manager -c "docker service scale my-app=${REPLICAS}"
