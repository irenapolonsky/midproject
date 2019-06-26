##################################################################################
# Security Groups - for k8s, jenkins, consul, mysql, prometheus
##################################################################################

resource "aws_security_group" "k8s_sg" {
  name        = "k8s_sg"
  description = "Allow ssh & consul inbound traffic"
  vpc_id      = "${aws_vpc.k8s_VPC.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all inside security group"
  }

  ingress {
    from_port   = 6443
    protocol    = "TCP"
    to_port     = 6443
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow k8s minion to join k8s master"

  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ssh from the world"
  }
   # Allow all HTTP External
  ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  # Allow all traffic from HTTP port 8080
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "TCP"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  # Allow all traffic from HTTPS port 443
  ingress {
    from_port = 443
    to_port = 443
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow traffic from HTTPS port 443"
  }
################ port to python module UI #########
  ingress {
    from_port   = 31616
    to_port     = 31616
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow from the world to app port"
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "Allow all outside security group"
  }

}

##################################################################################
# 4 Security Groups - for jenkins
##################################################################################
resource "aws_security_group" "jenkins_sg" {
  name = "jenkins_sg"
  description = "Security group for Jenkins"
  vpc_id = "${aws_vpc.k8s_VPC.id}"
  ######################
  # Allow ICMP from control host IP
  ingress {
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  # Allow all SSH External
  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  # Allow all HTTP External
  ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  # Allow all traffic from HTTP port 8080
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "TCP"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
    ingress {
    from_port = 8081
    to_port = 8081
    protocol = "TCP"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ######################
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}
##################################################################################
# Security Groups - for mysql
##################################################################################
resource "aws_security_group" "mysql_sg" {
  name        = "mysql_sg"
  vpc_id      = "${aws_vpc.k8s_VPC.id}"
  description = "Allow ssh & mysql inbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all inside security group"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ssh from the world"
  }


  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow accessing MYSQL from the worls"
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "Allow all outside security group"
  }
}

##################################################################################
# Security Groups - for monitoring
##################################################################################
resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring_sg"
  vpc_id      = "${aws_vpc.k8s_VPC.id}"
  description = "Allow ssh .... inbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all inside security group"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ssh from the world"
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Prometheus server"
  }

    ingress {
    from_port   = 9091
    to_port     = 9091
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Pushgateway"
  }

    ingress {
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Alertmanager"
  }
    ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "node exporter"
  }

    ingress {
    from_port   = 9101
    to_port     = 9101
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HAProxy exporter"
  }


    ingress {
    from_port   = 9104
    to_port     = 9104
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "MySQLd exporter"
  }

    ingress {
    from_port   = 9107
    to_port     = 9107
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "consul exporter"
  }

    ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "grafana"
  }

    ingress {
    from_port   = 9110
    to_port     = 9110
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Blackbox exporter"
  }
    ingress {
    from_port   = 9118
    to_port     = 9118
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Jenkins exporter"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "Allow all outside security group"
  }
}
##################################################################################
# 4 Security Groups - for consul
##################################################################################
resource "aws_security_group" "consul_sg" {
  name        = "consul_sg"
  vpc_id      = "${aws_vpc.k8s_VPC.id}"
  description = "Allow ssh & consul inbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all inside security group"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ssh from the world"
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "prometheus node exporter on every consul client"
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP: The HTTP API (TCP Only)"
  }

  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "DNS: The DNS server (TCP and UDP)"
  }

  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "server: Server RPC address (TCP Only)"
  }
  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "LAN Serf: The Serf LAN port (TCP and UDP)"
  }

    ingress {
    from_port   = 8302
    to_port     = 8302
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Wan Serf: The Serf WAN port TCP and UDP)"
  }

    ingress {
    from_port   = 21000
    to_port     = 21255
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Sidecar Proxy. Port number to use for automatically assigned sidecar service registrations"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "Allow all outside security group"
  }
}