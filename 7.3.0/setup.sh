#!/bin/bash

if [ $(id -u) -ne 0 ]
then
	echo "Please run the script as root, or using sudo."
	exit
fi

echo "Note: This script will restart your computer"
sleep 5
echo "Installing requirements ..."

USERNAME=$(logname)

## Update and install the requirements
apt update
apt install git -y

## Install python3.11
apt install python3.11 -y

# Download Forgeops 7.3.0
git clone https://github.com/ForgeRock/forgeops.git
cd forgeops
git checkout release/7.3-20230706

chown -R $USERNAME:$USERNAME ../forgeops 

### Install Third-Party requirements
cd ~
mkdir thirdparty
cd thirdparty

## Kubectl
curl -Lo kubectl "https://dl.k8s.io/release/v1.27.1/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

## Kubectx & Kubens
curl -Lo kubectx "https://github.com/ahmetb/kubectx/releases/download/v0.9.4/kubectx"
install -o root -g root -m 0755 kubectx /usr/local/bin/kubectx

curl -Lo kubens "https://github.com/ahmetb/kubectx/releases/download/v0.9.4/kubens"
install -o root -g root -m 0755 kubens /usr/local/bin/kubens

## Kustomize
curl -Lo install_kustomize.sh "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"
chmod 744 install_kustomize.sh
./install_kustomize.sh 5.0.1
install -o root -g root -m 0755 kustomize /usr/local/bin/kustomize

## Minikube
curl -Lo minikube "https://storage.googleapis.com/minikube/releases/v1.30.1/minikube-linux-amd64"
install -o root -g root -m 0755 minikube /usr/local/bin/minikube

## Docker engine
apt-get install ca-certificates curl gnupg -y
mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	
apt update

apt-get install docker-ce=5:20.10.24~3-0~ubuntu-jammy docker-ce-cli=5:20.10.24~3-0~ubuntu-jammy containerd.io docker-buildx-plugin docker-compose-plugin -y

# Adding permissions
usermod -aG docker $USERNAME

reboot
