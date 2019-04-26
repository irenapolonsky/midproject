##################################################################################
# 2 Security Groups - for jenkins and K8S
##################################################################################

resource "aws_security_group" "k8s-sg" {
  name        = "k8s-sg"
  description = "Allow ssh & consul inbound traffic"
  vpc_id      = "${aws_vpc.k8s_VPC.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all inside security group"
  }
   ingress {
    from_port   = 6443
    protocol    = "TCP"
    to_port     = 6443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ssh from the world"
  }
   # Allow all HTTP External
  ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  # Allow all traffic from HTTP port 8080
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "TCP"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  # Allow all traffic from HTTPS port 443
  ingress {
    from_port = 443
    to_port = 443
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow traffic from HTTPS port 443"
  }  ######################
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow consul UI access from the world"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "Allow all outside security group"
  }

}

##################################################################################
##################################################################################
resource "aws_security_group" "jenkins_sg" {
  name = "jenkins_sg"
  description = "Security group for Jenkins"
  vpc_id = "${aws_vpc.jenkins_VPC.id}"
  ######################
  # Allow ICMP from control host IP
  ingress {
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  # Allow all SSH External
  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  # Allow all HTTP External
  ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  # Allow all traffic from HTTP port 8080
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "TCP"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ######################
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}
