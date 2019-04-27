#####################################################################################################
#Allocate EC2 Jenkins instances
#####################################################################################################

resource "aws_instance" "jenkins_server" {
    count         = "${var.jenkins_servers}"
    ami           = "${var.jenkins_server_ami}"
    instance_type = "${var.jenkins_server_instance_type}"
    subnet_id              = "${aws_subnet.jenkins_Subnet_Public.id}"
    vpc_security_group_ids = ["${aws_security_group.jenkins_sg.id}"]
    key_name               = "${var.keypair_name}"
    depends_on = ["aws_internet_gateway.k8s_gw"]
    associate_public_ip_address = true

    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = "${file("jenkins_key_pair.pem")}"
    }
    provisioner "file" {
        source      = "id_rsa.pub"
        destination = ".ssh/id_rsa.pub"
 }
    provisioner "file" {
        source      = "id_rsa"
        destination = ".ssh/id_rsa"
 }
  provisioner "remote-exec" {
    inline = [
      "chmod 700 .ssh/id_rsa.pub",
      "chmod 700 .ssh/id_rsa",
      "cat .ssh/id_rsa.pub >> .ssh/authorized_keys",
          ]
  }
    user_data = <<EOF
#! /bin/bash
    echo "alias ls='ls -l -a --color -h --group-directories-first'" >> .bashrc
EOF

  tags {
      Owner           = "${var.owner}"
      Name            = "Jenkins-${count.index}"
      Comment = "${var.jenkins_server_instance_type}"
    }
}

#####################################################################################################
#Allocate EC2 Jenkins instances
#####################################################################################################

resource "aws_instance" "jenkins_slave" {
    count         = "${var.jenkins_slaves}"
    ami           = "${data.aws_ami.ubuntu.id}"
    instance_type = "${var.jenkins_slave_instance_type}"
    subnet_id              = "${aws_subnet.jenkins_Subnet_Private.id}"
    vpc_security_group_ids = ["${aws_security_group.jenkins_sg.id}"]
    key_name               = "${var.keypair_name}"
    associate_public_ip_address = false #====================

        connection {
        type = "ssh"
        user = "ubuntu"
        private_key = "${file("jenkins_key_pair.pem")}"
    }
    provisioner "file" {
        source      = "id_rsa.pub"
        destination = ".ssh/id_rsa.pub"
 }
    provisioner "file" {
        source      = "id_rsa"
        destination = ".ssh/id_rsa"
 }
  provisioner "remote-exec" {
    inline = [
      "chmod 700 .ssh/id_rsa.pub",
      "chmod 700 .ssh/id_rsa",
      "cat .ssh/id_rsa.pub >> .ssh/authorized_keys",
          ]
  }
    user_data = <<EOF
#! /bin/bash
    echo "alias ls='ls -l -a --color -h --group-directories-first'" >> .bashrc
EOF

    tags {
      Owner           = "${var.owner}"
      Name            = "Jenkins-slave${count.index}"
      Comment = "${var.jenkins_slave_instance_type}"
    }
}

