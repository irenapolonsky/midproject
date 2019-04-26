##################################################################################
# Create the user-data for the Consul server
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
# Get Ubuntu Canonical AMI
data "aws_ami" "ubuntu" {
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

