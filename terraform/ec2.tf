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
resource "aws_instance" "web_app" {
  count                  = var.number_of_azs
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = aws_subnet.public[count.index].id
  vpc_security_group_ids = [aws_security_group.web_app_sg.id]

  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
    
    # Store ALB DNS name in environment variable
    echo "WEB_SERVER_ALB_DNS=${aws_lb.web_server_alb.dns_name}" | sudo tee -a /etc/environment
    
    # Create a sample page that connects to the web server API
    cat <<HTML | sudo tee /var/www/html/index.html
    <h1>Web Application ${count.index + 1}</h1>
    <p>This app connects to the web server at: <strong>${aws_lb.web_server_alb.dns_name}</strong></p>
    <div id="result">Loading...</div>
    <script>
      async function fetchData() {
        try {
          const response = await fetch('http://${aws_lb.web_server_alb.dns_name}');
          if (!response.ok) {
            throw new Error('Network response was not ok');
          }
          const data = await response.json();
          document.getElementById('result').innerHTML = "API Response: " + JSON.stringify(data);
        } catch (error) {
          document.getElementById('result').innerHTML = "Error fetching API: " + error;
        }
      }
      fetchData();
    </script>
    HTML
  EOF

  depends_on = [aws_lb.web_server_alb]

  tags = { Name = "Web-Application-EC2-${count.index + 1}" }
}

# Launch Web Server EC2 Instances in Private Subnets
resource "aws_instance" "web_server" {
  count                  = var.number_of_azs
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = aws_subnet.private[count.index].id
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras enable docker
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker

    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd

    sudo usermod -aG docker ec2-user
    docker pull phulam11031996/web-server:latest
    docker run -d --name web-server -p 80:80 --restart unless-stopped phulam11031996/web-server:latest
  EOF

  tags = { Name = "Web-Server-EC2-${count.index + 1}" }
}

# Launch Bastion Host in Public Subnet
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public[0].id # Bastion should be in a public subnet
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true # Required for SSH access

  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  tags = { Name = "Bastion-Host" }
}


