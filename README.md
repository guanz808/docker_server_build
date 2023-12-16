# docker_server_build
Prerequisits:
* NFS share with the appropriate permissions for the dockers server to connect to.  The shared folder name is set to the variable $docker_shared_folder.  This shared folder will store the portainer configuration.
* In the shared folder the follollowing directories are pre-created
    * $docker_shared_folder => portainer-ce => data   

To run the install and configuration Ubuntu Server 23.10 (84-bit):  
```bash
cd $pwd
sudo apt update && sudo apt full-upgrade
wget -O - https://raw.githubusercontent.com/guanz808/docker_server_build/main/docker_group.sh | bash
newgrp docker  # restarts the shell to apply the group membership
wget -O - https://raw.githubusercontent.com/guanz808/docker_server_build/main/serverbuild.sh | bash
```

To Do:
* Fix error message "File '/etc/apt/keyrings/docker.gpg' exists. Overwrite? (y/N) y" this occurs if