#!/usr/bin/env bash
set -e

############ install ansible ############
apt-add-repository ppa":"ansible"/"ansible -y
apt-get update
apt-get install ansible -y
apt install python-pip -y
pip install python-consul

#########################################
echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
######################################### my session configs ########################
echo "ClientAliveInterval 120" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 720" >> /etc/ssh/sshd_config
echo "alias ls='ls -l -a --color -h --group-directories-first'" >> /home/ubuntu/.bashrc
echo "alias ls='ls -l -a --color -h --group-directories-first'" >> /root/.bashrc


cd /home/ubuntu
#########clone repo to get ansible files
git clone https://github.com/irenapolonsky/midproject.git
cd /home/ubuntu/midproject/
git checkout ${git_branch}
chown -R ubuntu:ubuntu /home/ubuntu/midproject

cd /home/ubuntu/midproject/k8s-ansible
###############Retrieve private ip to update k8s_master_ip in vars.yml
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
sed -i "s/masterIP/$PRIVATE_IP/g" "vars.yml"

###########################################################
sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts install-docker.yml
sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts k8s-common.yml
sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts k8s-master.yml
##########################################################

cd /home/ubuntu/midproject/k8s-ansible
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
echo "$PRIVATE_IP"
sed -i "s/local_ip/$PRIVATE_IP/g" "kube-dns.yml"

kubectl apply -f kube-dns.yml

####################################################consul section###################
cd /home/ubuntu/midproject/consul-ansible

############### modify consul config for k8s params ###################

sed -i "s/local-ipv4/$PRIVATE_IP/g" "config.json"
sed -i "s/consul-node-name/${consul_node_name}/g" "config.json"



###############Retrieve local hostname to update local_dns in vars.yml
PRIVATE_DNS=$(curl http://169.254.169.254/latest/meta-data/local-hostname)
sed -i "s/local_dns/$PRIVATE_DNS/g" "vars.yml"
sed -i "s/local_ip/$PRIVATE_IP/g" "vars.yml"

################################################### install consule client and configure it ##############
sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts consul-installation.yml
#########################################################################################################

###################################################  register k8s with consul #################
sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts k8s-registration.yml
sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts app-registration.yml


####################################### install prometheus node exporter ################################
cd /home/ubuntu/midproject/prometheus-ansible
sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts node_exporter-installation.yml
#########################################################################################################



touch /home/ubuntu/terraform_kmaster_success