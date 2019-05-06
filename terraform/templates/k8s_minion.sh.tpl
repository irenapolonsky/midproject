#! /bin/bash
apt-add-repository ppa":"ansible"/"ansible -y
apt-get update
apt-get install ansible -y
cd /usr/bin/
ln -s python3 python
echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
echo "alias ls='ls -l -a --color -h --group-directories-first'" >> /home/ubuntu/.bashrc

cd /home/ubuntu/
git clone https://github.com/irenapolonsky/midproject.git
cd /home/ubuntu/midproject/k8s/

##ansible-playbook -b -i hosts install-docker.yml
##ansible-playbook -b -i hosts k8s-common.yml
##ansible-playbook -b -i hosts k8s-minion.yml --limit 'masters' -vvv