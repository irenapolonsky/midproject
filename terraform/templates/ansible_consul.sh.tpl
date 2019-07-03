#!/usr/bin/env bash
set -e

############ install ansible ############
apt-add-repository ppa":"ansible"/"ansible -y
apt-get update
apt-get install ansible -y

#########################################
echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
######################################### my gitbash session configs ########################
echo "ClientAliveInterval 120" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 720" >> /etc/ssh/sshd_config
echo "alias ls='ls -l -a --color -h --group-directories-first'" >> /home/ubuntu/.bashrc
echo "alias ls='ls -l -a --color -h --group-directories-first'" >> /root/.bashrc


cd /home/ubuntu
#########copy repo to get ansible files
git clone https://github.com/irenapolonsky/midproject.git
cd /home/ubuntu/midproject/
git checkout ${git_branch}
chown -R ubuntu:ubuntu /home/ubuntu/midproject
cd /home/ubuntu/midproject/consul-ansible

###############Retrieve private ip to update k8s_master_ip in vars.yml
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
sed -i "s/local-ipv4/$PRIVATE_IP/g" "config.json"
sed -i "s/consul-node-name/${consul_node_name}/g" "config.json"

###########################################################
sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts consul-installation.yml -vvv
##################################################

####################################### install prometheus node exporter ################################
cd /home/ubuntu/midproject/prometheus-ansible
sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts node_exporter-installation.yml -vvv
#########################################################################################################

touch /home/ubuntu/terraform_consul_ansible_success