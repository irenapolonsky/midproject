resource "aws_instance" "monitoring_servers" {
  count = "${var.monitoring_servers}"
  ami           = "${data.aws_ami.ubuntu16_4.id}"
  instance_type = "${var.monitoring_instance_type}"
  subnet_id     = "${aws_subnet.k8s_Subnet_Public.id}"
  key_name      = "${var.keypair_name}"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.monitoring_sg.id}","${aws_security_group.consul_sg.id}"]
  iam_instance_profile   = "${aws_iam_instance_profile.ec2_profile.name}"

  user_data = "${element(data.template_file.monitoring.*.rendered, count.index)}"

    tags {
      Owner           = "${var.owner}"
      Name            = "monitoring-${count.index+1}"
      Comment = "${var.monitoring_instance_type}"
      Excercise = "mid-proj"
      Group = "monitoring"
    }

}