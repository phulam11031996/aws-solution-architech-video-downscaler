output "alb_dns_name" {
  value = aws_lb.web_app_alb.dns_name
}

output "web_server_private_ips" {
  description = "Private IPs of Web Server instances"
  value       = [for instance in aws_instance.web_server : instance.private_ip]
}

# Output the ALB DNS Name for Web Server
output "web_server_alb_dns" {
  description = "DNS name of the Web Server ALB"
  value       = aws_lb.web_server_alb.dns_name
}

