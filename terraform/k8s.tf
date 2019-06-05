#####################################################################################################
# Create Master instances for k8s-ansible
#####################################################################################################

resource "aws_instance" "k8s_master" {
  count     = "${var.k8s_masters}"
  ami       = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.k8s_master_instance_type}"
  subnet_id     = "${aws_subnet.k8s_Subnet_Public.id}"
  depends_on = ["aws_internet_gateway.k8s_igw"]

  vpc_security_group_ids = ["${aws_security_group.k8s-sg.id}"]

  key_name      = "${var.keypair_name}"
  associate_public_ip_address = true

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${file(var.pem_path)}"

    }

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
  user_data = "${element(data.template_file.k8s_master_template.*.rendered, count.index)}"

  tags = {
    Name = "k8s-master-${count.index+1}"
    Comment = "${var.k8s_master_instance_type}"
    Excercise = "mid-proj"
    Group = "masters"
  }

}

#####################################################################################################
#   null resource to wait until user_data scripts finish
#####################################################################################################

//resource "null_resource" "wait_for_k8s_masters" {
//
//  triggers = {
//    k8s_master_private_ip = "${aws_instance.k8s_master.private_ip}"
//  }
//  connection {
//    host = "${aws_instance.k8s_minion.*.id}"
//    }
//
//  provisioner "remote-exec" {
//    inline = [
//      "while ! [ -f /home/ubuntu/terraform_master_success ]; do sleep 1; done",
//
//    ]
//  }
//
//
//}

#####################################################################################################
# Create Minion instances for k8s-ansible
#####################################################################################################

resource "aws_instance" "k8s_minion" {
  count = "${var.k8s_minions}"
  ami       = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.k8s_minions_instance_type}"
  key_name      = "${var.keypair_name}"
#  subnet_id     = "${aws_subnet.k8s_Subnet_Private.id}"
  subnet_id     = "${aws_subnet.k8s_Subnet_Public.id}"

  iam_instance_profile   = "${aws_iam_instance_profile.ec2_profile.name}"
  vpc_security_group_ids = ["${aws_security_group.k8s-sg.id}"]

  depends_on = ["aws_internet_gateway.k8s_igw","aws_instance.k8s_master"]
  associate_public_ip_address = true

  user_data = "${element(data.template_file.k8s_minion_template.*.rendered, count.index)}"

    tags = {
      Name = "k8s-minion-${count.index+1}"
      Comment = "${var.k8s_minions_instance_type}"
      Excercise = "mid-proj"
      Group = "minions"
    }
  }