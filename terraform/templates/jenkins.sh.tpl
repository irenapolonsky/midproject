#!/usr/bin/env bash

###############################################
apt-add-repository ppa":"ansible"/"ansible -y
apt-get update
apt-get install ansible -y
apt-get install awscli -y
apt-get install jq -y

################################################
echo "alias ls='ls -l -a --color -h --group-directories-first'" >> /home/ubuntu/.bashrc
echo "alias ls='ls -l -a --color -h --group-directories-first'" >> /root/.bashrc
################################################

cd /home/ubuntu/
git clone https://github.com/irenapolonsky/midproject.git
chown -R ubuntu:ubuntu midproject

################################ ansible #####################################
cd /home/ubuntu/midproject/k8s
#sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts xxxxx.yml
################################################


touch /home/ubuntu/jenkins_success
