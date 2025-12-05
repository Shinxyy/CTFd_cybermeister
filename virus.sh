docker swarm init
docker node update --label-add='name=linux-1' $(docker node ls -q)

docker compose up -d