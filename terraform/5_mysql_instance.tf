resource "aws_instance" "mysql_servers" {
  count = "${var.mysql_servers}"
  ami           = "${lookup(var.mysql-ami, var.region)}"
  instance_type = "${var.mysql_instance_type}"
  subnet_id     = "${aws_subnet.k8s_Subnet_Public.id}"
  key_name      = "${var.keypair_name}"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.mysql_sg.id}", "${aws_security_group.consul_sg.id}"]
  iam_instance_profile   = "${aws_iam_instance_profile.ec2_profile.name}"

  user_data = "${element(data.template_file.consul_mysql.*.rendered, count.index)}"

    tags {
      Owner           = "${var.owner}"
      Name            = "consul-mysql-${count.index+1}"
      Comment = "${var.mysql_instance_type}"
      Excercise = "mid-proj"
      Group = "mysql"
    }

}