#!/usr/bin/env bash

###############################################
apt-add-repository ppa":"ansible"/"ansible -y
apt-get update
apt-get install ansible -y
apt-get install awscli -y
apt-get install jq -y

################################################
cd /usr/bin/
ln -s python3 python
echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
echo "alias ls='ls -l -a --color -h --group-directories-first'" >> /home/ubuntu/.bashrc
echo "alias ls='ls -l -a --color -h --group-directories-first'" >> /root/.bashrc

################################################
cd /home/ubuntu/
git clone https://github.com/irenapolonsky/midproject.git
chown -R ubuntu:ubuntu midproject
cd /home/ubuntu/midproject/k8s

###############Retrieve private ip of k8s_master and update vars.yml
MASTER_PRIVATE_IP=$(aws ec2 describe-instances --region us-east-1 --filters "Name=tag:Name,Values=k8s-master-1" \
| jq -r '.Reservations[].Instances[].PrivateIpAddress')

for i in "$MASTER_PRIVATE_IP";
do
    # Replacing single-spaces with empty
    if ! [[ -z "$i" ]]; then
        sed -i "s/masterIP/$i/g" "vars.yml"
    fi
done


####sed -i "s/masterIP/$MASTER_PRIVATE_IP/g" "vars.yml"


################################ ansible #####################################
sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts install-docker.yml
sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts k8s-common.yml
sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts k8s-minion.yml -vvv

touch /home/ubuntu/minion_success