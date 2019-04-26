Mid Course assignment


Mid Course assignment


In this assignment you will build a small prod like environment, this can AND SHOULD be used later as the base foundation for your final project


This is a draft for the final project so not everything may be 100% clear, if you have any question that needs clarification, please ping me and we’ll update the 
assignment.


For the mid project we would like you to complete the following


do everything automatically

Use the following tools

Ansible

Terraform

K8s

Docker

Consul

Create two VPCs (privet and public)

Using Ansible install and configure k8s

Pick a small application (from github) 

Run the following process (using Jenkins)

Clone your repo

Run tests (if exist)

Build a docker image of your application

Put new docker image in docker hub

Deploy your application in K8s and expose the service to the world

The application needs to register with consul 


You should add a test file (depending on the output of terraform)



To deploy the environment run:

 

git clone https://github.com/Israel_israeli/my_project_repo.git

cd my_repo/teraform

terraform apply --auto-approve

 

 

To check your environment run:

 

consul: curl XXXXXX:

Jenkins: YYYYY





# midproject
