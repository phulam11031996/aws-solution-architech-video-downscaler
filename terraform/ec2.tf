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
  vpc_security_group_ids = [aws_security_group.web_app_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
    
    # Store ALB DNS name in environment variable
    echo "WEB_SERVER_ALB_DNS=${aws_lb.web_server_alb.dns_name}" | sudo tee -a /etc/environment
    
    # Create a sample page that uses the ALB DNS
    cat <<HTML | sudo tee /var/www/html/index.html
    <h1>Web Application ${count.index + 1}</h1>
    <p>This app connects to web server at: ${aws_lb.web_server_alb.dns_name}</p>
    <div id="result">Loading...</div>
    <script>
      fetch('http://${aws_lb.web_server_alb.dns_name}')
        .then(response => response.text())
        .then(data => document.getElementById('result').innerHTML = data)
        .catch(error => document.getElementById('result').innerHTML = "Error: " + error);
    </script>
    HTML
  EOF

  depends_on = [aws_lb.web_server_alb]

  tags = { Name = "Web-Application-EC2-${count.index + 1}" }
}

# Launch EC2 Instances in Private Subnets
resource "aws_instance" "web_server" {
  count                  = var.number_of_azs
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = aws_subnet.public[count.index].id
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
    echo "<h1>Hello from Web Server EC2-${count.index + 1} in subnet $(hostname -I)</h1>" | sudo tee /var/www/html/index.html
    sudo sed -i 's/Listen 80/Listen 8080/g' /etc/httpd/conf/httpd.conf
    sudo systemctl restart httpd
  EOF

  tags = { Name = "WebServer-EC2-${count.index + 1}" }
}



# Launch Bastion Host in Public Subnet
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public[0].id # Bastion should be in a public subnet
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true # Required for SSH access

  tags = { Name = "Bastion-Host" }
}


