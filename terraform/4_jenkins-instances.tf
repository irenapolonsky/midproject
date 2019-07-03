#####################################################################################################
#Allocate EC2 Jenkins instances
#####################################################################################################

resource "aws_instance" "jenkins_server" {
    count         = "${var.jenkins_servers}"
    ami           = "${var.jenkins_server_ami}"
    instance_type = "${var.jenkins_server_instance_type}"
    subnet_id     = "${aws_subnet.k8s_Subnet_Public.id}"
    associate_public_ip_address = true

    vpc_security_group_ids = ["${aws_security_group.jenkins_sg.id}","${aws_security_group.consul_sg.id}"]
    key_name               = "${var.keypair_name}"
    iam_instance_profile   = "${aws_iam_instance_profile.ec2_profile.name}"

    depends_on = ["aws_internet_gateway.k8s_igw"]

    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = "${file(var.pem_path)}"
    }

    user_data = "${element(data.template_file.jenkins_template.*.rendered, count.index)}"

    provisioner "file" {
    source      = "${var.pem_path}"
    destination = ".ssh/jenkins_key_pair.pem"
    }

  provisioner "remote-exec" {
    inline = [
      "chmod 700 .ssh/jenkins_key_pair.pem",
      "cat .ssh/jenkins_key_pair.pem >> .ssh/id_rsa",
      "chmod 700 .ssh/id_rsa",
          ]
  }

    tags {
      Owner           = "${var.owner}"
      Name            = "Jenkins-server"
      Comment = "${var.jenkins_server_instance_type}"
      Excercise = "mid-proj"
      Group = "jenkins"
    }
}

#####################################################################################################
#Allocate EC2 Jenkins instances
#####################################################################################################

resource "aws_instance" "jenkins_slave" {
    count         = "${var.jenkins_slaves}"
    ami           = "${data.aws_ami.ubuntu16_4.id}"
    instance_type = "${var.jenkins_slave_instance_type}"
    subnet_id     = "${aws_subnet.k8s_Subnet_Public.id}"
    vpc_security_group_ids = ["${aws_security_group.jenkins_sg.id}"]
    key_name               = "${var.keypair_name}"
    associate_public_ip_address = true #====================

user_data = "${element(data.template_file.jenkins_template.*.rendered, count.index)}"

    tags {
      Owner           = "${var.owner}"
      Name            = "Jenkins-slave-${count.index+1}"
      Comment = "${var.jenkins_slave_instance_type}"
      Excercise = "mid-proj"
      Group = "jenkins"
    }
}

