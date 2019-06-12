##################################################################################
output "k8s masters" {
  value = ["${aws_instance.k8s_master.*.public_ip}" ]
}
##################################################################################
output "k8s minions" {
  value = ["${aws_instance.k8s_minion.*.public_ip}"]
}
##################################################################################

output "jenkins_server_public_ip" {
  value = "${join(",", aws_instance.jenkins_server.*.public_ip)}"
}

##################################################################################
output "consul servers" {
  value = ["${aws_instance.consul_server.*.public_ip}"]
}
output "consul clients" {
  value = ["${aws_instance.consul_client.*.public_ip}"]
}
##################################################################################
//output "consul clients" {
//  value = ["${aws_instance.consul_client.*.public_ip}"]
//}
##################################################################################