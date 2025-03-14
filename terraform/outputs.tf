output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}

output "ec2_public_ips" {
  description = "Public IPs of EC2 instances"
  value       = aws_instance.web[*].public_ip
}

