output "alb_dns_name" {
  value = "http://${aws_lb.web_app_alb.dns_name}"
}

