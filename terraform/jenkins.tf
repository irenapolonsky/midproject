#####################################################################################################
#Allocate EC2 Jenkins instances
#####################################################################################################

resource "aws_instance" "jenkins_server" {
    count         = "${var.jenkins_servers}"
    ami           = "${var.jenkins_server_ami}"
    instance_type = "${var.jenkins_server_instance_type}"
    subnet_id     = "${aws_subnet.k8s_Subnet_Public.id}"
    associate_public_ip_address = true

    vpc_security_group_ids = ["${aws_security_group.k8s-sg.id}"]
    key_name               = "${var.keypair_name}"
    iam_instance_profile   = "${aws_iam_instance_profile.ec2_profile.name}"

    depends_on = ["aws_internet_gateway.k8s_gw"]

    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = "${file("jenkins_key_pair.pem")}"
    }

    user_data = "${element(data.template_file.jenkins_template.*.rendered, count.index)}"

    provisioner "file" {
    source      = "${var.pem_path}"
    destination = ".ssh/jenkins_key_pair.pem"
    }


    tags {
      Owner           = "${var.owner}"
      Name            = "Jenkins-server"
      Comment = "${var.jenkins_server_instance_type}"
      Excercise = "mid-proj"
      Group = "jenkins-server"
    }
}

#####################################################################################################
#Allocate EC2 Jenkins instances
#####################################################################################################

resource "aws_instance" "jenkins_slave" {
    count         = "${var.jenkins_slaves}"
    ami           = "${data.aws_ami.ubuntu.id}"
    instance_type = "${var.jenkins_slave_instance_type}"
    subnet_id     = "${aws_subnet.k8s_Subnet_Public.id}"
    vpc_security_group_ids = ["${aws_security_group.k8s-sg.id}"]
    key_name               = "${var.keypair_name}"
    associate_public_ip_address = true #====================

user_data = "${element(data.template_file.jenkins_template.*.rendered, count.index)}"

    tags {
      Owner           = "${var.owner}"
      Name            = "Jenkins-slave${count.index}"
      Comment = "${var.jenkins_slave_instance_type}"
      Excercise = "mid-proj"
      Group = "jenkins-slaves"
    }
}

