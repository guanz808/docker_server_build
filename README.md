# docker_server_build
To run the install and configuration Ubuntu Docker server:
apt update && apt upgrade -y
apt install curl git -y
cd $pwd
curl -o ~/serverbuild.sh https://raw.githubusercontent.com/guanz808/docker_server_build/main/serverbuild.sh
chmod +x ~/serverbuild.sh
sudo ~/serverbuild.sh -y