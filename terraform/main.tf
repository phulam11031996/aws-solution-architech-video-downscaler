# Define AWS region as a variable
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

# Define key pair variable
variable "key_name" {
  description = "The name of the SSH key pair"
  type        = string
}

# AWS Provider
provider "aws" {
  region = var.aws_region
}

# Security Group
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_security_group"
  description = "Allow SSH and HTTP access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere (change for security)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP access from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Fetch the latest Amazon Linux 2 AMI dynamically
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# EC2 Instance
resource "aws_instance" "web" {
  ami             = data.aws_ami.latest_amazon_linux.id
  instance_type   = "t2.micro"
  key_name        = var.key_name
  security_groups = [aws_security_group.ec2_sg.name]

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user

    # Pull the latest Docker image from DockerHub
    sudo docker pull ${var.dockerhub_image}

    # Run the container on port 80
    sudo docker run -d -p 80:80 ${var.dockerhub_image}
  EOF

  tags = {
    Name = "Terraform-EC2"
  }
}

# Output Public IP
output "instance_public_ip" {
  value = aws_instance.web.public_ip
}
