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
sed -zi '/neofetch/!s/$/\neofetch/' ~/.bashrc

# Run neofetch
neofetch

# Install Docker and Docker Compose (Ubuntu)
echo "## Install Docker and Docker Compose (Ubuntu)"
# Set up Docker's apt repository
sudo apt update -y
sudo apt install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg -y
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

# Post install
# To create the docker group and add your user
#echo "## Post install"
#echo "## Create the docker group and add your user"
#sudo groupadd docker
#check_command "sudo groupadd docker"

# Function to check if a group exists
group_exists() {
    local group_name="$1"
    getent group "$group_name" >/dev/null 2>&1
}

# Define the group name
docker_group_name="docker"

# Check if the group exists
if group_exists "$docker_group_name"; then
    echo "Group '$docker_group_name' already exists. Skipping group creation."
else
    # Create the group
    sudo groupadd "$docker_group_name"

    # Check if the group creation was successful
    if [ $? -eq 0 ]; then
        echo "Group '$docker_group_name' created successfully."
    else
        echo "Error creating group '$docker_group_name'."
        exit 1
    fi
fi

#sudo usermod -aG docker $USER
#check_command "sudo usermod -aG docker $USER"

# Function to check if the user is a member of a group
user_is_member_of_group() {
    local username="$1"
    local groupname="$2"
    groups "$username" | grep -q "\<$groupname\>"
}

# Define the group name
docker_group_name="docker"

# Check if the user is a member of the "docker" group
if user_is_member_of_group "$USER" "$docker_group_name"; then
    echo "User '$USER' is already a member of the '$docker_group_name' group. Skipping group membership addition."
else
    # Add the user to the "docker" group
    sudo usermod -aG "$docker_group_name" "$USER"
    # refresh the group membership
    #newgrp docker
    #exit

    # Check if the user addition was successful
    if [ $? -eq 0 ]; then
        echo "User '$USER' added to the '$docker_group_name' group successfully."
    else
        echo "Error adding user '$USER' to the '$docker_group_name' group."
        exit 1
    fi
fi

# Function to check if a group exists
#group_exists() {
#    local group_name="$1"
#    getent group "$group_name" >/dev/null 2>&1
#}
#
## Function to check if the user is a member of a group
#user_is_member_of_group() {
#    local username="$1"
#    local groupname="$2"
#    groups "$username" | grep -q "\<$groupname\>"
#}
#
## Define the group name
#docker_group_name="docker"
#
## Check if the group exists
#if group_exists "$docker_group_name"; then
#    echo "Group '$docker_group_name' already exists. Skipping group creation."
#else
#    # Create the group
#    sudo groupadd "$docker_group_name"
#
#    # Check if the group creation was successful
#    if [ $? -eq 0 ]; then
#        echo "Group '$docker_group_name' created successfully."
#    else
#        echo "Error creating group '$docker_group_name'."
#        exit 1
#    fi
#fi
#
## Check if the user is a member of the "docker" group
#if user_is_member_of_group "$USER" "$docker_group_name"; then
#    echo "User '$USER' is already a member of the '$docker_group_name' group. Skipping group membership addition."
#else
#    # Add the user to the "docker" group
#    sudo usermod -aG "$docker_group_name" "$USER"
#    newgrp "$docker_group_name"
#
#    # Check if the user addition was successful
#    if [ $? -eq 0 ]; then
#        echo "User '$USER' added to the '$docker_group_name' group successfully."
#    else
#        echo "Error adding user '$USER' to the '$docker_group_name' group."
#        exit 1
#    fi
#fi


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

newgrp docker
exit