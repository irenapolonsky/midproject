
provider "aws" {
  region = "${var.region}"
  version = "~> 1.0"
}
##################################################################################
# VPC
##################################################################################
resource "aws_vpc" "jenkins_VPC" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "jenkins_vpc"
    Comment = "jenkins"
  }
}resource "aws_vpc" "k8s_VPC" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "k8c_vpc"
  }
}
##################################################################################
# subnets
##################################################################################
resource "aws_subnet" "k8s_Subnet_Public" {
  vpc_id     = "${aws_vpc.k8s_VPC.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.availabilityZone1}"
  tags = {
    Name = "k8s_subnet_public"
  }
}
resource "aws_subnet" "k8s_Subnet_Private" {
  vpc_id     = "${aws_vpc.k8s_VPC.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.availabilityZone1}"
  tags = {
    Name = "k8s_subnet_private"
  }
}
##################################################################################
resource "aws_subnet" "jenkins_Subnet_Public" {
  vpc_id     = "${aws_vpc.jenkins_VPC.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.availabilityZone2}"
  tags = {
    Name = "jenkins_Subnet_Public"
  }
}

resource "aws_subnet" "jenkins_Subnet_Private" {
  vpc_id     = "${aws_vpc.jenkins_VPC.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.availabilityZone2}"
  tags = {
    Name = "k8s_subnet_prjenkins_Subnet_Private"
  }
}
##################################################################################
# Internet Gateways
##################################################################################
resource "aws_internet_gateway" "k8s_gw" {
  vpc_id = "${aws_vpc.k8s_VPC.id}"
  tags = {
    Name = "k8s_gw"
  }
}
resource "aws_internet_gateway" "jenkins_gw" {
  vpc_id = "${aws_vpc.jenkins_VPC.id}"
  tags = {
    Name = "jenkins_gw"
  }
}
##################################################################################
# Route Tables
##################################################################################
resource "aws_route_table" "k8s_internet" {
  vpc_id = "${aws_vpc.k8s_VPC.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.k8s_gw.id}"
  }
  tags = {
    Name = "k8s_internet"
  }
}
##################################################################################
resource "aws_route_table" "jenkins_internet" {
  vpc_id = "${aws_vpc.jenkins_VPC.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.jenkins_gw.id}"
  }
  tags = {
    Name = "jenkins_rt"
  }
}
##################################################################################
# Subnet & Route
##################################################################################
resource "aws_route_table_association" "jenkins_public" {
  subnet_id      = "${aws_subnet.jenkins_Subnet_Public.id}"
  route_table_id = "${aws_route_table.jenkins_internet.id}"
}
resource "aws_route_table_association" "jenkins_private" {
  subnet_id      = "${aws_subnet.jenkins_Subnet_Private.id}"
  route_table_id = "${aws_route_table.jenkins_internet.id}"
}
#############################################################
resource "aws_route_table_association" "k8s_public" {
  subnet_id      = "${aws_subnet.k8s_Subnet_Public.id}"
  route_table_id = "${aws_route_table.k8s_internet.id}"
}

resource "aws_route_table_association" "k8s_private" {
  subnet_id      = "${aws_subnet.k8s_Subnet_Public.id}"
  route_table_id = "${aws_route_table.k8s_internet.id}"
}
##################################################################################
# Security Groups
##################################################################################

# Create an IAM role for the auto-join
resource "aws_iam_role" "consul-join" {
  name               = "opsschool-consul-join"
  assume_role_policy = "${file("${path.module}/templates/policies/assume-role.json")}"
}

# Create the policy
resource "aws_iam_policy" "consul-join" {
  name        = "opsschool-consul-join"
  description = "Allows Consul nodes to describe instances for joining."
  policy      = "${file("${path.module}/templates/policies/describe-instances.json")}"
}

# Attach the policy
resource "aws_iam_policy_attachment" "consul-join" {
  name       = "opsschool-consul-join"
  roles      = ["${aws_iam_role.consul-join.name}"]
  policy_arn = "${aws_iam_policy.consul-join.arn}"
}

# Create the instance profile
resource "aws_iam_instance_profile" "consul-join" {
  name  = "opsschool-consul-join"
  role = "${aws_iam_role.consul-join.name}"
}