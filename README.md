**Overview**

1. Terraform is running from windows desktop and creates cluster with 10 ec2 instances
    Consul servers/leaders (3)
    K8s master and minions(1+2)
    Jenkins master and slaves(1+1)
    Mysql (1)
    Monitoring(1)
2. All instances are located on one public subnet 
3. Every instance assigned a specific security group that provides access to the necessary ports – according to the service needs
    SSH Key (pem file) is provided to Jenkins server via provisioner file (to configure kubernetes cd plugin) 
4. Every instance has it’s template&datasource to provide user_data

**User Data: Installation and configuration** 

1. Ansible is installed on every instance
2. Git repo is cloned on every instance
3. All ansible scripts are running locally using scripts from repo
        no need to deal with ssh
        installations are running on parallel on all instances  
4.  For configurations:
        Metadata for current instance (local-ipv4 and local-hostname) is retrieved from http://169.254.169.254/latest/meta-data
        Metadata for other instances is passed via datasource & template
5. Last command in every user_data script – touch file to verify that bash script finished successfully (set –e) 

**Flow**

1. Access Consul ui – see that all relevant services are up and running
2. Start Jenkins build-test-deploy pipe
        Clones repo/branch
        Builds app docker image
        Tests app against external mysql
        On success pushes image to docker
        Creates/applies resources deployment and service of type load balancer on k8s cluster
3. On jmeter 
        send requests to public IP of k8s master, port 31616 – see response
        send requests to mysql – see data in the table app_requests@employees 
        
**Consul**

1. Install 3 consul servers 
2. Install clients on instances (ansible playbook)
3. Register services with basic health checks (ansible playbook)
        Jenkins
        K8s
        Mysql
        Prometheus
        Grafana
4. Service config adjustment (for Jenkins service discovery)
    `ExecStart=/usr/local/bin/consul agent -client 0.0.0.0 -pid-file=/opt/consul/consul.pid -config-dir=/etc/consul.d`
5. Added local dns (ip-10-0-1-145.ec2.internal) to dnsmasq consul config  
    Is pointed by kube-dns stubdomain
6.  Installed Prometheus node_exporter 

**Jenkins**

1. Jenkins master – docker based on Jenkins/Jenkins:lts (3 weeks ago) 
2. Jenkins slaves - docker based on ubuntu 18.04
3. Created aws ami and used to build an instance
     To use consul service discovery  
        In Kubernetes Continuous Deploy plugin (k8s-master ip):
	        `docker run -d --name jenkins --network=host --rm -v /var/run/docker.sock:/var/run/docker.sock -p 	8080:8080 jenkins-master:lts` 
     In cicd pipe stage – connect to mysql
            `docker run -d --network=host --name webserver --rm -p 5000:5000 ${DockerImageLatest}`
4. Installed Consul client
5. Installed Prometheus node_exporter

**Kubernetes**

1.Basic installation with ansible scripts (Mickey’s)
    1 master , 2 minions
2. Expose external services (mysql) to Pods via Consul
3. Implementing stubdomain on kube-dns instead of native coredns
4. Installed Consul client 
5. Installed Prometheus node_exporter 
6. Not (yet) integrated with Prometheus

**Mysql**

1. Used pre-defined ami with mysql 
2. Added new user irena – to use in app connection
3. Added new table to be used by app
4. Installed consul client
5. Installed Prometheus node_exporter to provide node metrics
6. Not installed (yet) Prometheus mysql_exporter to provide db metrics 

**Monitoring**

1. Prometheus installed on instance Monitoring (ansible script from user-data)
2. Node_exporters installed on all relevant servers
3. Planned
    Integration with kubernetes
    Mysql_exporter
    Consul_exporter
    Jenkins_exporter
4. Grafana installed on instance Monitoring (directly in user-data)
5. data source is provided in /etc/grafana/provisioning/datasources/
6. dashboard is provided in /etc/grafana/provisioning/dashboards


**Commands**

To present the project:
1. mkdir opsschool_final_project
2. cd opsschool_final_project
3. git clone https://github.com/irenapolonsky/midproject.git
4. cd midproject/
5. git checkout final_project
6. cd terraform/
7. terraform init
8. terraform plan
9. terraform apply --auto-approve
10. Open:  
    consul_ip:8500
     
    jenkins_ip:8080
    
    monitoring_ip:9090 and 3000
    
    k8s_ip:31616
    
    jmeter - on desktop
    
11. Git Bash for k8s_ip:
    cd midproject/k8s-ansible/
    
    `kubectl apply -f kube-dns.yml`
    
    `kubectl get pods -n kube-system -l k8s-app=kube-dns`