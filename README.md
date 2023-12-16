# docker_server_build
Prerequisits:
* NFS share with the appropriate permissions for the dockers server to connect to.  The shared folder name is set to the variable $docker_shared_folder.  This shared folder will store the portainer configuration.
* In the shared folder the follollowing directories are pre-created
    * $docker_shared_folder => portainer-ce => data   

To run the install and configuration Ubuntu Server 23.10 (84-bit):  
```bash
sudo apt install curl git -y
cd $pwd
curl -o ~/docker_group.sh https://raw.githubusercontent.com/guanz808/docker_server_build/main/docker_group.sh
curl -o ~/serverbuild.sh https://raw.githubusercontent.com/guanz808/docker_server_build/main/serverbuild.sh
chmod +x ~/docker_group.sh
chmod +x ~/serverbuild.sh
~/docker_group.sh -y
~/serverbuild.sh -y
```