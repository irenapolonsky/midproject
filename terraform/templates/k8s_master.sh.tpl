#!/usr/bin/env bash
set -e

############ install ansible ############
apt-add-repository ppa":"ansible"/"ansible -y
apt-get update
apt-get install ansible -y
#########################################
echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
echo "alias ls='ls -l -a --color -h --group-directories-first'" >> /home/ubuntu/.bashrc
echo "alias ls='ls -l -a --color -h --group-directories-first'" >> /root/.bashrc
cd /home/ubuntu

#########copy repo to get ansible files
git clone https://github.com/irenapolonsky/midproject.git
chown -R ubuntu:ubuntu midproject
cd /home/ubuntu/midproject/k8s

###############Retrieve private ip to update k8s_master_ip in vars.yml
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
sed -i "s/masterIP/$PRIVATE_IP/g" "vars.yml"

##sudo -u "ubuntu" "sudo ansible-playbook --connection=local -b -i hosts install-docker.yml -vvv"
sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts install-docker.yml -vvv
sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts k8s-common.yml -vvv
sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts k8s-master.yml -vvv
##################################################
