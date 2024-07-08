output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}

output "lb_dns" {
  value = aws_lb.web_lb.dns_name

}

output "web_server_1" {
  value = aws_instance.web_server.private_ip

}

output "web_server_2" {
  value = aws_instance.web_server_2.private_ip

}

