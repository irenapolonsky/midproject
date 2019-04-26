#####################################################################################################
# Create Master instances for k8s
#####################################################################################################

resource "aws_instance" "k8s_master" {
  count     = "${var.k8s_masters}"
  ami       = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.k8s_master_instance_type}"
  key_name      = "${var.keypair_name}"
  subnet_id     = "${aws_subnet.k8s_Subnet_Public.id}"
  private_ip = "10.0.1.100"
  vpc_security_group_ids = ["${aws_security_group.k8s-sg.id}"]
  depends_on = ["aws_internet_gateway.k8s_gw"]
  associate_public_ip_address = true

  connection {
    type = "ssh"
    host = "${aws_instance.k8s_master.public_ip}"
    user = "ubuntu"
    private_key = "${file("jenkins_key_pair.pem")}"
    }

  provisioner "file" {
    source      = "id_rsa"
    destination = ".ssh/id_rsa"
 }

  provisioner "file" {
    source      = "id_rsa.pub"
    destination = ".ssh/id_rsa.pub"
 }
  provisioner "file" {
    source      = "jenkins_key_pair.pem"
    destination = "jenkins_key_pair.pem"
 }

  provisioner "file" {
    source      = "../k8s.zip"
    destination = "/var/tmp/k8s.zip"

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
apt-add-repository ppa":"ansible"/"ansible -y
apt-get update
apt-get install ansible -y
apt install unzip
echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
echo "alias ls='ls -l -a --color -h --group-directories-first'" >> /home/ubuntu/.bashrc
cd /home/ubuntu/
su ubuntu
unzip /var/tmp/k8s.zip
cd k8s
echo "$${private_ip}" >> hosts
EOF

  tags = {
    Name = "k8s-master-${count.index+1}"
    Comment = "${var.k8s_master_instance_type}"
  }

}
#####################################################################################################
# Create Minion instances for k8s
#####################################################################################################

resource "aws_instance" "k8s_minion" {
  count = "${var.k8s_minions}"
  ami       = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.k8s_minions_instance_type}"
  key_name      = "${var.keypair_name}"
#  subnet_id     = "${aws_subnet.k8s_Subnet_Private.id}"
  subnet_id     = "${aws_subnet.k8s_Subnet_Public.id}"  #======================
  vpc_security_group_ids = ["${aws_security_group.k8s-sg.id}"]
  depends_on = ["aws_internet_gateway.k8s_gw"]  #======================
  associate_public_ip_address = true   #======================

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
apt-add-repository ppa":"ansible"/"ansible -y
apt-get update
apt-get install ansible -y
git clone / s3 download /
ansible
cd /usr/bin/
ln -s python3 python
apt install unzip
echo "alias ls='ls -l -a --color -h --group-directories-first'" >> /home/ubuntu/.bashrc


EOF
  tags = {
    Name = "k8s-minion-${count.index+1}"
    Comment = "${var.k8s_master_instance_type}"
  }
}






