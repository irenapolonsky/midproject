To present the project:

mkdir opsschool-midproj-demo

cd opsschool-midproj-demo/

git clone https://github.com/irenapolonsky/midproject.git

cd midproject/

git checkout jenkins_config

cd terraform/

terraform init

terraform plan

terraform apply --auto-approve

Open jenkins jenkinsip:8080

jenkins/jenkins

Credentials

kubeconfig - replace k8s_masterIP by actual from terraform

run Demo-Pipe

In browser: - port 31616

k8s_masterIP:31616 