#!/usr/bin/env bash
set -e
###############################################
apt-add-repository ppa":"ansible"/"ansible -y
apt-get update
apt-get install ansible -y
apt-get install awscli -y
apt-get install jq -y

################################################
echo "ClientAliveInterval 120" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 720" >> /etc/ssh/sshd_config
echo "alias ls='ls -l -a --color -h --group-directories-first'" >> /home/ubuntu/.bashrc
echo "alias ls='ls -l -a --color -h --group-directories-first'" >> /root/.bashrc
################################################

cd /home/ubuntu/
git clone https://github.com/irenapolonsky/midproject.git
cd /home/ubuntu/midproject/
git checkout jenkins_config
chown -R ubuntu:ubuntu /home/ubuntu/midproject
cd /home/ubuntu/midproject/

################################ ansible #####################################
cd /home/ubuntu/midproject/k8s
#sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts jenkins-master.yml -vvv
################################################


touch /home/ubuntu/jenkins_success
