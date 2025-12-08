docker swarm init
docker node update --label-add='name=linux-1' $(docker node ls -q)

#? Clone the CTFd whale repo
git clone https://github.com/frankli0324/ctfd-whale.git CTFd/plugins

docker compose up -d
