##################################################################################
# Create the user-data for k8s-ansible master and minions
##################################################################################
data "template_file" "k8s_master_template" {
  template = "${file("${path.module}/templates/k8s_master.sh.tpl")}"
  vars = {
    git_branch =  "${var.git_branch}"
  }
}

data "template_file" "k8s_minion_template" {
  template = "${file("${path.module}/templates/k8s_minion.sh.tpl")}"
  depends_on = ["aws_internet_gateway.k8s_igw","aws_instance.k8s_master"]
  vars = {
      k8s_master_ip = "${aws_instance.k8s_master.private_ip}"
      git_branch =  "${var.git_branch}"

  }
}

##################################################################################
# Create  user-data for jenkins-config server
##################################################################################
data "template_file" "jenkins_template" {
  template = "${file("${path.module}/templates/jenkins.sh.tpl")}"
  vars = {
    git_branch =  "${var.git_branch}"
  }
}
##################################################################################
# Create  user-data for consul server
##################################################################################

data "template_file" "consul_server" {
  count    = "${var.consul_servers}"
  template = "${file("${path.module}/templates/consul.sh.tpl")}"

  vars {
    consul_version = "${var.consul_version}"
    config = <<EOF
     "node_name": "consul-server-${count.index+1}",
     "server": true,
     "bootstrap_expect": 3,
     "ui": true,
     "client_addr": "0.0.0.0"
    EOF
  }
}
##################################################################################
# Create the user-data for the Consul agent
##################################################################################

data "template_file" "consul_client" {
  count    = "${var.consul_clients}"
  template = "${file("${path.module}/templates/consul.sh.tpl")}"

  vars {
    consul_version = "${var.consul_version}"
    config = <<EOF
     "node_name": "consul-client-${count.index+1}",
     "enable_script_checks": true,
     "server": false
    EOF
  }
}

data "template_file" "ansible_consul_client" {
  count    = "${var.consul_clients}"
  template = "${file("${path.module}/templates/ansible_consul.sh.tpl")}"

  vars {
    git_branch =  "${var.git_branch}"
    consul_version = "${var.consul_version}"
    config = <<EOF
     "node_name": "ansible-consul-client-${count.index+1}",
     "enable_script_checks": true,
     "server": false
    EOF
  }
}

data "template_file" "consul_mysql" {
  count    = "${var.mysql_servers}"
  template = "${file("${path.module}/templates/mysql.sh.tpl")}"

  vars {
    git_branch =  "${var.git_branch}"
    consul_version = "${var.consul_version}"
    config = <<EOF
     "node_name": "consul-mysql-${count.index+1}",
     "enable_script_checks": true,
     "server": false
    EOF
  }
}
data "template_file" "monitoring" {
  count    = "${var.monitoring_servers}"
  template = "${file("${path.module}/templates/monitoring.sh.tpl")}"
  vars = {
    git_branch =  "${var.git_branch}"
  }
}
# Get Ubuntu Canonical AMI
data "aws_ami" "ubuntu16_4" {
    most_recent = true
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
    owners = ["099720109477"] # Canonical
}



