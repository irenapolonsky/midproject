##################################################################################
# Roles
##################################################################################

# Create an IAM role for the auto-join
resource "aws_iam_role" "consul-join" {
  name               = "consul-join"
  assume_role_policy = "${file("${path.module}/templates/policies/assume-role-consul.json")}"
}

# Create the policy
resource "aws_iam_policy" "consul-join" {
  name        = "consul-join"
  description = "Allows Consul nodes to describe instances for joining."
  policy      = "${file("${path.module}/templates/policies/describe-instances.json")}"
}

# Attach the policy
resource "aws_iam_policy_attachment" "consul-join" {
  name       = "consul-join"
  roles      = ["${aws_iam_role.consul-join.name}"]
  policy_arn = "${aws_iam_policy.consul-join.arn}"
}

# Create the instance profile
resource "aws_iam_instance_profile" "consul-join" {
  name  = "consul-join"
  role = "${aws_iam_role.consul-join.name}"
}
##################################################################################

# Create an IAM role for midproject masters
resource "aws_iam_role" "ec2_role" {
  name               = "ec2_role"
  assume_role_policy = "${file("${path.module}/templates/policies/assume-role-consul.json")}"
}

# Create the policy
resource "aws_iam_policy" "ec2_policy" {
  name        = "ec2_policy"
  description = "Allows minion nodes to describe instances for getting k8s master private ip."
  policy      = "${file("${path.module}/templates/policies/describe-instances.json")}"
}


# Attach the policy
resource "aws_iam_policy_attachment" "ec2_role_policy" {
  name       = "ec2_role_policy"
  roles      = ["${aws_iam_role.ec2_role.name}"]
  policy_arn = "${aws_iam_policy.ec2_policy.arn}"

}

# Create the instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name  = "ec2_profile"
  role = "${aws_iam_role.ec2_role.name}"
}

######################################################################################
#
######################################################################################
