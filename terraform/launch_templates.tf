# Fetch Latest Amazon Linux 2 AMI
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

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

resource "aws_launch_template" "web_server_lt" {
  name_prefix   = "web-server-lt-"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_s3_publish_sns_profile.name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras enable docker
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user

    docker pull phulam11031996/web-server:latest

    docker run -d \
      --name web-server \
      -e AWS_REGION=${var.aws_region} \
      -e TOPIC_ARN=${aws_sns_topic.video_scaler_topic.arn} \
      -e S3_BUCKET_NAME=${aws_s3_bucket.video_scaler_bucket.bucket} \
      -p 8080:80 \
      --restart unless-stopped \
      phulam11031996/web-server:latest
  EOF
  )

  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Web-Server-ASG"
    }
  }
}

