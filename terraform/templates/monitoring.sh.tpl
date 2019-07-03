#!/usr/bin/env bash
set -e
###############################################
apt-add-repository ppa":"ansible"/"ansible -y
apt-get update
apt-get install ansible -y
apt install python-pip -y
pip install python-consul
curl https://packages.grafana.com/gpg.key | sudo apt-key add -
add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
apt-get update
apt-get -y install grafana

################################################
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

cp /home/ubuntu/midproject/prometheus-ansible/prometheus_grafana.yml /etc/grafana/provisioning/datasources/
cp /home/ubuntu/midproject/prometheus-ansible/grafana_dashboard.yml /etc/grafana/provisioning/dashboards
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

####################################################consul section###################
cd /home/ubuntu/midproject/consul-ansible

############### modify consul config for jenkins params ###################
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
PRIVATE_DNS=$(curl http://169.254.169.254/latest/meta-data/local-hostname)
sed -i "s/local-ipv4/$PRIVATE_IP/g" "config.json"
sed -i "s/consul-node-name/${consul_node_name}/g" "config.json"
sed -i "s/local_ip/$PRIVATE_IP/g" "vars.yml"
sed -i "s/local_dns/$PRIVATE_DNS/g" "vars.yml"

#################################### install consul client and configure it#######################
sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts consul-installation.yml

#################################### register prometheus with consul #################
sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts prometheus-registration.yml
sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts grafana-registration.yml -vvv

cd /home/ubuntu/midproject/prometheus-ansible
################################################### install consul client and configure it ##############
sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts prometheus-installation.yml

sudo -u ubuntu sudo ansible-playbook --connection=local -b -i hosts node_exporter-installation.yml
#########################################################################################################

touch /home/ubuntu/terraform_monitoring_success
