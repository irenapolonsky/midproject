#!/usr/bin/env bash
set -e

############################################### install Ansible and AWS CLI ###########
apt-add-repository ppa":"ansible"/"ansible -y
apt-get update
apt-get install ansible -y
apt-get install awscli -y
apt-get install jq -y

################################################
cd /usr/bin/
# ln -s python3 python
#########################################
echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
######################################### my session configs ########################
echo "ClientAliveInterval 120" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 720" >> /etc/ssh/sshd_config
echo "alias ls='ls -l -a --color -h --group-directories-first'" >> /home/ubuntu/.bashrc
echo "alias ls='ls -l -a --color -h --group-directories-first'" >> /root/.bashrc

################################################
cd /home/ubuntu/
git clone https://github.com/irenapolonsky/midproject.git
cd /home/ubuntu/midproject/
git checkout ${git_branch}
chown -R ubuntu:ubuntu /home/ubuntu/midproject
cd /home/ubuntu/midproject/k8s-ansible

sed -i "s/masterIP/${k8s_master_ip}/g" "vars.yml" ### - does not work if terminated instances exist

################################ ansible #####################################
sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts install-docker.yml
sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts k8s-common.yml -vvv
sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts k8s-minion.yml -vvv

touch /home/ubuntu/terraform_kminion_success