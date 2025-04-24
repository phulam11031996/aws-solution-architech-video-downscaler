
resource "aws_launch_template" "web_app_lt" {
  name_prefix   = "web-app-lt-"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_profile.name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo yum update -y

    sudo amazon-linux-extras install docker -y
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user

    docker pull phulam11031996/web-app:latest

    docker run -d \
      --name web-app \
      -p 80:80 \
      --restart unless-stopped \
      -e ALB_DNS=${aws_lb.web_app_alb.dns_name} \
      phulam11031996/web-app:latest
  EOF
  )

  vpc_security_group_ids = [aws_security_group.web_app_sg.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Web-App-ASG"
    }
  }
}
