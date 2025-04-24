# Application Load Balancer for Web Application
resource "aws_lb" "web_app_alb" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_app_alb_sg.id]
  subnets            = aws_subnet.public[*].id

  tags = { Name = "application-load-balancer" }
}

# Target Group
resource "aws_lb_target_group" "web_app_alb_tg" {
  name     = "alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = { Name = "alb-target-group" }
}

# # Attach EC2 Instances to Target Group
# resource "aws_lb_target_group_attachment" "ec2_attachment" {
#   count            = var.number_of_azs
#   target_group_arn = aws_lb_target_group.web_app_alb_tg.arn
#   target_id        = aws_instance.web_app[count.index].id
#   port             = 80
# }

# ALB Listener for HTTP
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app_alb_tg.arn
  }
}


# Application Load Balancer for Web Server
resource "aws_lb" "web_server_alb" {
  name               = "web-server-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_server_alb_sg.id]
  subnets            = aws_subnet.private[*].id

  tags = { Name = "web-server-alb" }
}


# ALB Target Group
resource "aws_lb_target_group" "web_server_tg" {
  name     = "web-server-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  tags = { Name = "web-server-tg" }
}

# Add HTTP Listener on port 80 for web_server_alb
resource "aws_lb_listener" "web_server_http_80_listener" {
  load_balancer_arn = aws_lb.web_server_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_server_tg.arn
  }
}


# Attach Web Server EC2 Instances to ALB Target Group
resource "aws_lb_target_group_attachment" "web_server_attachment" {
  count            = var.number_of_azs
  target_group_arn = aws_lb_target_group.web_server_tg.arn
  target_id        = aws_instance.web_server[count.index].id
  port             = 8080
}

# ALB Listener for Web Server
resource "aws_lb_listener" "web_server_listener" {
  load_balancer_arn = aws_lb.web_server_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_server_tg.arn
  }
}

