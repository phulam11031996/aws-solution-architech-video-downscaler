# Fetch Latest Amazon Linux 2 AMI
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Launch EC2 Instances in Public Subnets
resource "aws_instance" "web" {
  count                  = var.number_of_azs
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = aws_subnet.public[count.index].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
    echo "<h1>Hello from EC2-${count.index + 1} in subnet $(hostname -I)</h1>" | sudo tee /var/www/html/index.html
  EOF

  tags = { Name = "Terraform-EC2-${count.index + 1}" }
}
