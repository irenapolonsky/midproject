
##################################################################################
# Create the Consul cluster - server - on the same subnet with k8s-ansible master
##################################################################################

resource "aws_instance" "consul_server" {
  count = "${var.consul_servers}"
  ami           = "${lookup(var.consul_server_ami, var.region)}"
  instance_type = "${var.consul_server_instance_type}"
  key_name      = "${var.keypair_name}"
  subnet_id              = "${aws_subnet.k8s_Subnet_Public.id}"
  iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
  vpc_security_group_ids = ["${aws_security_group.k8s-sg.id}"]
  depends_on = ["aws_internet_gateway.k8s_igw"]
  associate_public_ip_address = true
  tags = {
    Name = "opsschool-server-${count.index+1}"
    consul_server = "true"
    Comment = "consul-server"
    Excercise = "mid-proj"
  }
  user_data = "${element(data.template_file.consul_server.*.rendered, count.index)}"
}
##################################################################################
# Create the Consul Client
##################################################################################

//resource "aws_instance" "consul_client" {
//  count = "${var.consul_clients}"
//  ami           = "${lookup(var.consul_server_ami, var.region)}"
//  instance_type = "${var.consul_server_instance_type}"
//  key_name      = "${var.keypair_name}"
//  subnet_id     = "${aws_subnet.k8s_Subnet_Private.id}"
//  iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
//  vpc_security_group_ids = ["${aws_security_group.k8s-ansible-sg.id}"]
//
//  tags = {
//    Name = "opsschool-client-${count.index+1}"
//    Comment = "consul"
//  }
//  user_data = "${element(data.template_file.consul_client.*.rendered, count.index)}"
//}
