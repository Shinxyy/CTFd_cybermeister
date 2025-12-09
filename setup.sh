#!/bin/bash
echo "Deleting System32..."

# Clean up any existing setup
echo "Cleaning up existing containers and networks..."
docker compose down -v 2>/dev/null || true

# Remove all stopped containers
echo "Removing all stopped containers..."
docker container prune -f

# Remove all unused networks
echo "Removing unused networks..."
docker network prune -f

# Remove all unused volumes
echo "Removing unused volumes..."
docker volume prune -f

# Remove all unused images
echo "Removing unused images..."
docker image prune -a -f

# Clean up local data directories
echo "Cleaning up local data directories..."
rm -rf .data

# Check if already in swarm mode
if ! docker info | grep -q "Swarm: active"; then
    echo "Initializing Docker Swarm..."
    docker swarm init
else
    echo "Docker Swarm already active"
fi

# Update node label
echo "Setting node label..."
docker node update --label-add='name=linux-1' $(docker node ls -q)

# # Clone the CTFd whale repo if it doesn't exist
# if [ ! -d "CTFd/plugins/ctfd_whale" ]; then
#     echo "Cloning CTFd-Whale plugin..."
#     git clone https://github.com/StijnvdMade/ctfd-whale.git CTFd/plugins/ctfd_whale
# else
#     echo "CTFd-Whale plugin already exists, skipping clone"
# fi

# Build and start services
echo "Building and starting Docker Compose services..."
docker-compose -f CTFd/docker-compose.yml exec ctfd python manage.py set_config whale:auto_connect_network


# # Configure CTFd Whale with Docker API settings
# echo "Configuring CTFd Whale..."
# docker exec ctfd_cybermeister-db-1 mariadb -uctfd -pctfd ctfd -e "
# INSERT INTO config (key, value) VALUES ('whale_api_url', 'tcp://host.docker.internal:2375') 
# ON DUPLICATE KEY UPDATE value='tcp://host.docker.internal:2375';
# " 2>/dev/null || echo "Whale config will be set on first run"

# Restart CTFd to ensure everything is loaded
echo "Restarting CTFd..."
docker compose restart ctfd

echo "Setup complete! CTFd is running on http://localhost:8000"
echo "Docker Swarm could cause a delay in the initial startup of CTFd Whale plugin as it connects to the Docker API."
echo "Don't forget to set the CTFd API URL in the Whale plugin settings after logging into CTFd."
echo "The Docker API URL should be: tcp://host.docker.internal:2375"
