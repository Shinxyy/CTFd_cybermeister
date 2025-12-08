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

# Clone the CTFd whale repo if it doesn't exist
if [ ! -d "CTFd/plugins/ctfd-whale" ]; then
    echo "Cloning CTFd-Whale plugin..."
    git clone https://github.com/frankli0324/ctfd-whale.git CTFd/plugins/ctfd-whale
else
    echo "CTFd-Whale plugin already exists, skipping clone"
fi

# Start services
echo "Starting Docker Compose services..."
docker compose up -d
