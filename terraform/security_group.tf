# Security Group for Web Application EC2 Instances
resource "aws_security_group" "web_app_sg" {
  name        = "web-app-sg"
  description = "Allow HTTP access"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open for public access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "web-app-sg" }
}


# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to internet
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to internet
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "alb-security-group" }
}

# Security Group for Bastion Host
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH from a specific IP range"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your actual IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "bastion-sg" }
}

# Allow SSH from Bastion to Web Application EC2
resource "aws_security_group_rule" "allow_http_from_bastion" {
  type              = "egress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = aws_security_group.bastion_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# ---------------------------------------------
# Security Group for Web Server EC2 Instances
resource "aws_security_group" "web_server_sg" {
  name        = "web-server-sg"
  description = "Allow HTTP access from ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 8080 # Updated to 8080
    to_port         = 8080 # Updated to 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_server_alb_sg.id] # Allow traffic only from ALB
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "web-server-sg" }
}

# Security Group for Web Server ALB
resource "aws_security_group" "web_server_alb_sg" {
  name        = "web-server-alb-sg"
  description = "Allow traffic to web server from the web app"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 8080 # Updated to 8080
    to_port         = 8080 # Updated to 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "web-server-alb-sg" }
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
  port     = 8080 # Updated to 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  tags = { Name = "web-server-tg" }
}

# ALB Listener for Web Server
resource "aws_lb_listener" "web_server_listener" {
  load_balancer_arn = aws_lb.web_server_alb.arn
  port              = 8080 # Updated to 8080
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
  port             = 8080 # Updated to 8080
}

# ---------------------------------------------
resource "aws_eip" "nat" {
  domain = "vpc"
}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # Use the first public subnet

  tags = {
    Name = "NAT-Gateway"
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "Private-RT"
  }
}
resource "aws_route_table_association" "private" {
  count          = var.number_of_azs
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
# ---------------------------------------------


