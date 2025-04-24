# Fetch Latest Amazon Linux 2 AMI
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# # Launch EC2 Instances in Public Subnets
# resource "aws_instance" "web_app" {
#   count                  = var.number_of_azs
#   ami                    = data.aws_ami.latest_amazon_linux.id
#   instance_type          = "t2.micro"
#   key_name               = var.key_name
#   subnet_id              = aws_subnet.public[count.index].id
#   vpc_security_group_ids = [aws_security_group.web_app_sg.id]
#
#   iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
#
#   user_data = <<-EOF
#   #!/bin/bash
#   sudo yum update -y
#
#   sudo amazon-linux-extras install docker -y
#   sudo systemctl start docker
#   sudo systemctl enable docker
#   sudo usermod -aG docker ec2-user
#   
#   docker pull phulam11031996/web-app:latest
#   
#   docker run -d \
#     --name web-app \
#     -p 80:80 \
#     --restart unless-stopped \
#     -e ALB_DNS=${aws_lb.web_server_alb.dns_name} \
#     phulam11031996/web-app:latest
#   EOF
#
#   depends_on = [aws_lb.web_server_alb]
#   tags       = { Name = "Web-Application-${count.index + 1}" }
# }

# Launch Web Server EC2 Instances in Private Subnets
resource "aws_instance" "web_server" {
  count                  = var.number_of_azs
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = aws_subnet.private[count.index].id
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  iam_instance_profile = aws_iam_instance_profile.ssm_s3_publish_sns_profile.name

  user_data = <<-EOF
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

  tags = { Name = "Web-Server-${count.index + 1}" }
}

# Create six EC2 instances (3 in each subnet) for video downscaling
resource "aws_instance" "video_downscaler" {
  count         = var.number_of_azs * 3
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id     = aws_subnet.private_video[floor(count.index / 3)].id

  iam_instance_profile = aws_iam_instance_profile.ssm_s3_read_sqs_profile.name

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras enable docker
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user
    docker pull phulam11031996/web-worker:latest

    index=${count.index}
    x_group=$(((index % 3) + 1))
    if [ "$x_group" -eq 1 ]; then
      export SQS_QUEUE_URL="${aws_sqs_queue.video_x1_queue.url}"
    elif [ "$x_group" -eq 2 ]; then
      export SQS_QUEUE_URL="${aws_sqs_queue.video_x2_queue.url}"
    else
      export SQS_QUEUE_URL="${aws_sqs_queue.video_x3_queue.url}"
    fi

    docker run -d \
      --name web-worker \
      -e SQS_QUEUE_URL=$SQS_QUEUE_URL \
      -e AWS_REGION=${var.aws_region} \
      --restart unless-stopped \
      phulam11031996/web-worker:latest
  EOF

  tags = {
    Name = "Video-Downscaler-X${(count.index % 3) + 1}-${floor(count.index / 3) + 1}"
  }
}
