#!/bin/bash

hostname=devdckr.dajays.dev  # PROD => dckr.dajays.com => devdckr.dajays.dev
nas_ip=192.168.1.11
portainer_container_name=portainer_dev # PROD => portainer DEV => portainer_dev
docker_shared_folder=docker_dev # PROD => docker DEV => docker_dev

# Function to check if a command was successful check if a command was successful
check_command() {
    if [ $? -eq 0 ]; then
        echo "Command Successful: $1"
    else
        echo "Error executing command: $1"
        exit 1
    fi
}

# Updates
echo "## Updates"
sudo apt update -y
check_command "sudo apt update -y"

sudo apt upgrade -y
check_command "sudo apt upgrade -y"

# Turn Off Firewall
echo "## Check Firewall Status"
if sudo ufw status | grep -q "Status: active"; then
    echo "Firewall is active. Turning it off..."
    sudo ufw disable
    check_command "sudo ufw disable"
else
    echo "Firewall is not active. Skipping..."
fi
check_command "sudo ufw disable -y"

# Setup Hostname
echo "## Setup Hostname"
hostnamectl
sudo hostnamectl set-hostname $hostname
hostnamectl
check_command "sudo hostnamectl set-hostname $hostname"
check_command "sudo tee -a /etc/hosts"

# Set Time Zone
echo "## Set Time Zone"
sudo timedatectl set-timezone Pacific/Honolulu
timedatectl status
check_command "sudo timedatectl set-timezone Pacific/Honolulu -y"

# Install Neofetch
echo "## Install Neofetch"
sudo apt update -y
check_command "sudo apt update -y"

sudo apt install neofetch -y
check_command "sudo apt install neofetch -y"

# Download neofetch config.conf file
mkdir -p ~/.config/neofetch
curl -o ~/.config/neofetch/config.conf https://raw.githubusercontent.com/guanz808/dotfiles/main/.config/neofetch/config.conf

# Append neofetch to the end of .bashrc if it doesn't exist
echo -e "\n" "# Run Neofetch"
sed -zi '/neofetch/!s/$/\nneofetch/' ~/.bashrc

# Run neofetch
#neofetch

# Install Docker and Docker Compose (Ubuntu)
echo "## Install Docker and Docker Compose (Ubuntu)"
# Set up Docker's apt repository
sudo apt update -y
sudo apt install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
check_command "Setting up Docker's apt repository"

# Install the Docker packages
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
check_command "Installing Docker packages"

# Install Portainer
# Install Portainer data directory to an NFS share
# Create an /portainer-ce/data folder share on your NAS
# Create an NFS 4 share to the /protainer-ce folder
# Grant the appropriate permissions to the share
echo "## Install Portainer"
echo "## Install Portainer data directory to an NFS share (make sure to create the NFS share on your NAS first)"

sudo apt install nfs-common -y
check_command "sudo apt install nfs-common -y"

# Function to check if a Docker volume exists
docker_volume_exists() {
    local volume_name="$1"
    docker volume inspect "$volume_name" >/dev/null 2>&1
}

# Check if the Docker volume exists
if docker_volume_exists "portainer_data"; then
    echo "Docker volume 'portainer_data' already exists. Skipping creation."
else
    nas_ip="192.168.1.11"  # Replace with your NAS IP
    docker_shared_folder="docker_dev"  # Replace with your folder name

    # Create the Docker volume
    docker volume create --name portainer_data \
      --driver local \
      --opt type=nfs \
      --opt o=addr="$nas_ip",rw,noatime,rsize=8192,wsize=8192,tcp,timeo=14,nfsvers=4 \
      --opt device=:/volume1/"$docker_shared_folder"/portainer-ce/data

    # Check if the creation was successful
    if [ $? -eq 0 ]; then
        echo "Docker volume 'portainer_data' created successfully."
    else
        echo "Error creating Docker volume 'portainer_data'."
        exit 1
    fi
fi

# Function to check if a Docker container exists
docker_container_exists() {
    local container_name="$1"
    docker inspect "$container_name" >/dev/null 2>&1
}

# Check if the Docker container exists
if docker_container_exists "$portainer_container_name"; then
    echo "Docker container '$portainer_container_name' already exists. Skipping container creation."
else
    # Run the Docker container
    docker run -d -p 8000:8000 -p 9000:9000 \
      --name="$portainer_container_name" \
      --restart=on-failure \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v portainer_data:/data \
      portainer/portainer-ce:latest

    # Check if the container creation was successful
    if [ $? -eq 0 ]; then
        echo "Docker container '$portainer_container_name' created successfully."
    else
        echo "Error creating Docker container '$portainer_container_name'."
        exit 1
    fi
fi