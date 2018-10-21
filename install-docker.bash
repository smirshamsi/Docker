###########################################################
#             This script installs and launches           #
#             a docker container with environment         #
#                  suitable for use by                    #
#                   A Data Science group                  #
#                                                         #
#              Maintainer: Sahar Mirshamsi                #
###########################################################
# NOTE: if used on an OS other than Ubuntu 16, replace the
#       <repo> based on table at this link
#https://docs.docker.com/engine/installation/linux/ubuntulinux/
###########################################################

##### Clone the repository ##########
rm -r -y ~/Docker-Containers
mkdir ~/Docker-Containers
cd Docker-Containers
git clone https://github.com/smirshamsi/ds-docker
cp ~/Docker-Containers/ds-docker/dockerfile ~/Docker-Containers
#mv ~/Docker-Containers/install-docker.bash ~
rm -r ~/Docker-Containers/ds-docker

echo "Do you want Ubuntu with Apache web server? Type in Y or N "
read answer

if [ $answer = 'Y' ];then
        #sed -i 's/FROM ubuntu:latest/\#FROM ubuntu:latest/g' ~/Docker-Containers/dockerfile
        #sed -i 's/#FROM nickistre\/ubuntu-lamp/FROM nickistre\/ubuntu-lamp/g' ~/Docker-Containers/dockerfile
        sed -i 's/#RUN apt-get install -y apache2/RUN apt-get install -y apache2/g' ~/Docker-Containers/dockerfile
elif [ $answer ='N' ];then
        echo "Installing without Apache"
else
        echo "Your answer did not match Y or N! Assuming N and installing WITHOUT Apache!"
fi

echo "what do you want to name/tag your container? Please enter your answer here"
read TagName
echo "******* dockerfile and install script are obtained from repository ********"

##### Install docker services ######
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates
sudo apt-key adv \
               --keyserver hkp://ha.pool.sks-keyservers.net:80 \
               --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

#echo "<REPO>" | sudo tee /etc/apt/sources.list.d/docker.list
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list

sudo apt-get update
apt-cache policy docker-engine
sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual

sudo apt-get update
sudo apt-get install -y docker-engine
sudo service docker start

echo "********** Docker is installed **********"

##### Install mail services ######

sudo DEBIAN_FRONTEND=noninteractive  apt-get install -y mailutils

echo "********** Mailutils is installed **********"

##### Create the image and launch the docker container #####

cd ~/Docker-Containers
sudo docker build --no-cache -t "simple_flask:dockerfile" .
sudo docker run --name $TagName -i -t -v ~/data:/home/DS-Production/Archive -p 2222:22 -p 80:80 -p 4430:443 -p 25:25 $(sudo docker images -q|head -1)

