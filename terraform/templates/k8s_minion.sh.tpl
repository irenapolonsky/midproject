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
git checkout jenkins_config
chown -R ubuntu:ubuntu /home/ubuntu/midproject
cd /home/ubuntu/midproject/k8s-ansible

###############Retrieve private ip of k8s_master and update vars.yml
MASTER_PRIVATE_IP=$(aws ec2 describe-instances --region us-east-1 --filters "Name=tag:Name,Values=k8s-master-1" \
| jq -r '.Reservations[].Instances[].PrivateIpAddress')

##sed -i "s/masterIP/$MASTER_PRIVATE_IP/g" "vars.yml" ### - does not work if terminated instances exist

##============ to ignore null private_IP of the terminated instances with the same tag
for i in "$MASTER_PRIVATE_IP";
do
    if ! [[ -z "$i" ]]; then
        sed -i "s/masterIP/$i/g" vars.yml
    fi
done

################################ ansible #####################################
sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts install-docker.yml
sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts k8s-common.yml
sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts k8s-minion.yml -vvv

touch /home/ubuntu/terraform_minion_success