# docker_server_build
### Prerequisits:
* NFS share with the appropriate permissions for the dockers server to connect to.  The shared folder name is set to the variable $docker_shared_folder.  This shared folder will store the portainer configuration.
* In the shared folder the follollowing directories are pre-created
    * $docker_shared_folder => portainer-ce => data   

To run the install and configuration Ubuntu Server 23.10 (84-bit):  
### Updates  
```bash
cd $pwd
sudo apt update -y
sudo apt full-upgrade -y
```
**NOTE**: If running on a raspberry pi reboot before proceeding, to apply the kernal updates.  
### Deploy  
* #### docker_group.sh    
    This script creates a docker group and adds the current user to the group.  This allows the current user to run docker commands with sudo.  
* #### serverbuild.sh  
1. Updates
1. Turns off firewall
1. Sets the host name
1. Sets the timezone 
1. Installs and configures Neofetch
1. Install docker and docker compose
1. Creates a docker volume to connect to your NFS share
1. Install Portainer and map the Portainer data directory to your NFS share
```bash
wget -O - https://raw.githubusercontent.com/guanz808/docker_server_build/main/docker_group.sh | bash
newgrp docker  # restarts the shell to apply the group membership
wget -O - https://raw.githubusercontent.com/guanz808/docker_server_build/main/serverbuild.sh | bash
```

### To Do:
* Fix error message "File '/etc/apt/keyrings/docker.gpg' exists. Overwrite? (y/N) y" this occurs if