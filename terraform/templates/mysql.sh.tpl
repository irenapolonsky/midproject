#!/usr/bin/env bash
set -e

echo "Grabbing IPs..."
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

echo "Installing dependencies..."
sudo apt-get -qq update &>/dev/null
sudo apt-get -yqq install unzip dnsmasq &>/dev/null

echo "Configuring dnsmasq..."
cat << EODMCF >/etc/dnsmasq.d/10-consul
# Enable forward lookup of the 'consul' domain:
server=/consul/127.0.0.1#8600
EODMCF

systemctl restart dnsmasq

echo "Fetching Consul..."
cd /tmp
curl -sLo consul.zip https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_linux_amd64.zip

echo "Installing Consul..."
unzip consul.zip >/dev/null
sudo chmod +x consul
sudo mv consul /usr/local/bin/consul

# Setup consul.sh.tpl
echo "setting up consul.sh.tpl..."
sudo mkdir -p /opt/consul
sudo mkdir -p /etc/consul.d
sudo mkdir -p /run/consul
sudo mkdir -p /var/log/consul
sudo tee /etc/consul.d/config.json > /dev/null <<EOF
{
  "advertise_addr": "$PRIVATE_IP",
  "data_dir": "/opt/consul",
  "datacenter": "irena",
  "encrypt": "uDBV4e+LbFW3019YKPxIrg==",
  "disable_remote_exec": true,
  "disable_update_check": true,
  "leave_on_terminate": true,
  "log_file": "/var/log/consul",
  "retry_join": ["provider=aws tag_key=consul_server tag_value=true"],
  ${config}
}
EOF

# Create user & grant ownership of folders
echo "Create user & grant ownership of folders"
sudo useradd consul
sudo chown -R consul:consul /opt/consul /etc/consul.d /run/consul

################################################
echo "ClientAliveInterval 120" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 720" >> /etc/ssh/sshd_config
echo "alias ls='ls -l -a --color -h --group-directories-first'" >> /home/ubuntu/.bashrc
echo "alias ls='ls -l -a --color -h --group-directories-first'" >> /root/.bashrc
################################################

echo "Configuring consul service"
sudo tee /etc/systemd/system/consul.service > /dev/null <<"EOF"
[Unit]
Description=Consul service discovery agent
Requires=network-online.target
After=network.target

[Service]
User=consul
Group=consul
PIDFile=/run/consul/consul.pid
Restart=on-failure
Environment=GOMAXPROCS=2
ExecStartPre=[ -f "/run/consul/consul.pid" ] && /usr/bin/rm -f /run/consul/consul.pid
ExecStart=/usr/local/bin/consul agent -pid-file=/run/consul/consul.pid -config-dir=/etc/consul.d
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGINT
TimeoutStopSec=5

[Install]
WantedBy=multi-user.target
EOF

#sudo echo "DNS=127.0.0.1" >> /etc/systemd/resolved.conf
#sudo echo "Domains=~consul" >> /etc/systemd/resolved.conf
#iptables -t nat -A OUTPUT -d localhost -p udp -m udp --dport 53 -j REDIRECT --to-ports 8600
#iptables -t nat -A OUTPUT -d localhost -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 8600

echo "consul service configured"
sudo systemctl daemon-reload
sudo systemctl enable consul.service
sudo systemctl start consul.service

cd /home/ubuntu/
git clone https://github.com/irenapolonsky/midproject.git
cd /home/ubuntu/midproject/
git checkout ${git_branch}
chown -R ubuntu:ubuntu /home/ubuntu/midproject


touch /home/ubuntu/terraform_consul_success
touch /home/ubuntu/terraform_mysql_success