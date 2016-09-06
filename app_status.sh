SERVICE_NAME=$1

vagrant ssh manager -c "docker service ps ${SERVICE_NAME}"
