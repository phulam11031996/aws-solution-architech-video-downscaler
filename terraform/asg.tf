resource "aws_autoscaling_group" "web_app_asg" {
  name                      = "web-app-asg"
  desired_capacity          = 1
  max_size                  = 1
  min_size                  = 1
  vpc_zone_identifier       = aws_subnet.public[*].id
  health_check_type         = "EC2"
  health_check_grace_period = 300
  target_group_arns         = [aws_lb_target_group.web_app_alb_tg.arn]

  launch_template {
    id      = aws_launch_template.web_app_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Web-App-ASG"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web_server_asg" {
  name                      = "web-server-asg"
  desired_capacity          = 1
  max_size                  = 1
  min_size                  = 1
  vpc_zone_identifier       = aws_subnet.private[*].id
  health_check_type         = "EC2"
  health_check_grace_period = 300
  target_group_arns         = [aws_lb_target_group.web_server_tg.arn]

  launch_template {
    id      = aws_launch_template.web_server_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Web-Server-ASG"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

