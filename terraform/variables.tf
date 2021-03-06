##################################################################################
# PROVIDER VARIABLES
###################################################################################
#variable "access_key" {}
#variable "secret_key" {}

variable "region" {
  description = "AWS region for VMs"
  default = "us-east-1"
}

variable "pem_path" {
  type = "string"
  default = "c:\\Users\\polon\\opsschool\\jenkins_key_pair.pem"
}

variable "git_branch" {
  type = "string"
  default = "master"
}

variable "prefix" {
  type = "string"
  default = ""
}
##################################################################################
# VPC RESOURCES VARIABLES
##################################################################################

variable "vpcCIDRblock" {
  description = "VPC CIDR block"
  default = "10.0.0.0/16"
}

##################################################################################
# Subnet & Route Table RESOURCES VARIABLES
##################################################################################

variable "availabilityZone1" {
        default = "us-east-1a"
}
variable "availabilityZone2" {
        default = "us-east-1b"
}
variable "subnetCIDRblock1" {
        default = "10.0.1.0/24"
}
variable "subnetCIDRblock2" {
        default = "10.0.2.0/24"
}

variable "destinationCIDRblock" {
        default = "0.0.0.0/0"
}
variable "mapPublicIP" {
        default = true
}
variable "associate_public_ip_address" {
        default = true
}

##################################################################################
# INSTANCE RESOURCES VARIABLES
##################################################################################
#----------------------------------------Instance Type-----------------------------
variable "jenkins_server_instance_type" {
  description = "instance for Jenkins master node"
  default = "t3.small"
#  default = "t2.micro"
}
variable "jenkins_slave_instance_type" {
  description = "instance for Jenkins slave node"
  default = "t3.micro"
}
variable "k8s_master_instance_type" {
  description = "instance for k8s servers slave node"
#  default = "t2.medium"
  default = "t3.micro"
}
variable "k8s_minions_instance_type" {
  description = "instance for k8s servers slave node"
  default = "t2.micro"
}
variable "consul_server_instance_type" {
  description = "instance for Consul server node"
  default = "t2.micro"
}
variable "consul_client_instance_type" {
  description = "instance for Consul and k8s minions"
  default = "t2.micro"
}

variable "mysql_instance_type" {
  description = "instance for Consul and k8s minions"
  default = "t2.micro"
}

variable "monitoring_instance_type" {
  description = "instance for Consul and k8s minions"
  default = "t2.micro"
}
#----------------------------------------Instance AMI-----------------------------
variable "jenkins_server_ami" {
    description = "AMI for jenkins Master with docker slave"
    default = "ami-0eaf557e5c9c122fa" ### my ami with kubernetes plugin
}
variable "jenkins_slave_ami" {
  description = "default is not used. latest canonical is selected"
  default = "ami-028d6461780695a43"
}

variable "consul_server_ami" {
  description = "ami to use - based on region"
  default = {
    "us-east-1" = "ami-0565af6e282977273"
    "us-east-2" = "ami-0653e888ec96eab9b"
  }
}

variable "mysql-ami" {
  description = "default is not used. latest canonical is selected"
  default = {
#    "us-east-1" = "ami-04bd9486c7cc16415"
    "us-east-1" = "ami-0efce9ba58ce2de43"
  }
}

variable "monitoring-ami" {
  description = "default is not used. latest canonical is selected"
  default = {
    "us-east-1" = "ami-04bd9486c7cc16415"
  }
}
#---------------------------------Key Pair name------------------------------------
variable "keypair_name" {
  description = "Name of the KeyPair used for all nodes"
  default = "jenkins_key_pair"
}
#----------------------------------DNS Support-------------------------------------

variable "dnsSupport" {
 default = true
}
variable "dnsHostNames" {
        default = true
}
#--------------------------------------------------------------------------------------
variable "instanceTenancy" {
  description = "standard tenancy"
  default = "default"
}

variable jenkins_servers {
  default = "1"
}

variable mysql_servers {
  default = "1"
}

variable jenkins_slaves {
  default = "1"
}
variable "k8s_masters" {
  description = "The number of k8 master instances"
  default = 1
}
variable "k8s_minions" {
  description = "The number of k8 minion instances"
  default = 2
}
variable "consul_servers" {
  description = "The number of consul servers."
  default = 3
}
variable "consul_clients" {
  description = "The number of consul client instances"
  default = 0
}

variable monitoring_servers {
  default = "1"
}
##################################################################################
# Provisioning VARIABLES
##################################################################################

variable "consul_version" {
  description = "The version of Consul to install (server and client)."
  default     = "1.4.0"
}

variable owner {
  default = "Jenkins"
}
