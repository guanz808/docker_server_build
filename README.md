# docker_server_build
Prerequisits:
* NFS share with the appropriate permissions for the dockers server to connect to.  The shared folder name is set to the variable $docker_shared_folder.  This shared folder will store the portainer configuration.
* In the shared folder the follollowing directories are pre-created
    * $docker_shared_folder => portainer-ce => data   

To run the install and configuration Ubuntu Server 23.10 (84-bit):  
```bash
sudo apt update && apt upgrade -y
sudo apt install curl git -y
cd $pwd
curl -o ~/serverbuild.sh https://raw.githubusercontent.com/guanz808/docker_server_build/main/serverbuild.sh
chmod +x ~/serverbuild.sh
sudo ~/serverbuild.sh -y
```