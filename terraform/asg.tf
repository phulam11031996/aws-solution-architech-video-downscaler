# AWS Auto Scaling Groups for Web Application and Video Downscalers
resource "aws_autoscaling_group" "web_app_asg" {
  name                      = "web-app-asg"
  desired_capacity          = 2
  max_size                  = 2
  min_size                  = 2
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
    value               = "Web-Application-ASG"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# AWS Auto Scaling Groups for Web Server and Video Downscalers
resource "aws_autoscaling_group" "web_server_asg" {
  name                      = "web-server-asg"
  desired_capacity          = 2
  max_size                  = 2
  min_size                  = 2
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

# AWS Auto Scaling Groups for Video Downscalers
resource "aws_autoscaling_group" "video_downscaler_x1_asg" {
  name                      = "video-downscaler-x1-asg"
  desired_capacity          = 2
  max_size                  = 10
  min_size                  = 2
  vpc_zone_identifier       = aws_subnet.private_video[*].id
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.video_downscaler_x1.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Video-Downscaler-X1-ASG"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "video_downscaler_x2_asg" {
  name                      = "video-downscaler-x2-asg"
  desired_capacity          = 2
  max_size                  = 10
  min_size                  = 2
  vpc_zone_identifier       = aws_subnet.private_video[*].id
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.video_downscaler_x2.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Video-Downscaler-X2-ASG"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "video_downscaler_x3_asg" {
  name                      = "video-downscaler-x3-asg"
  desired_capacity          = 2
  max_size                  = 10
  min_size                  = 2
  vpc_zone_identifier       = aws_subnet.private_video[*].id
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.video_downscaler_x3.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Video-Downscaler-X3-ASG"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# AWS Auto Scaling Policies for Video Downscalers
resource "aws_autoscaling_policy" "scale_out_x1" {
  name                   = "scale-out-x1"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.video_downscaler_x1_asg.name
}

resource "aws_autoscaling_policy" "scale_in_x1" {
  name                   = "scale-in-x1"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.video_downscaler_x1_asg.name
}

resource "aws_autoscaling_policy" "scale_out_x2" {
  name                   = "scale-out-x2"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.video_downscaler_x2_asg.name
}

resource "aws_autoscaling_policy" "scale_in_x2" {
  name                   = "scale-in-x2"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.video_downscaler_x2_asg.name
}

resource "aws_autoscaling_policy" "scale_out_x3" {
  name                   = "scale-out-x3"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.video_downscaler_x3_asg.name
}

resource "aws_autoscaling_policy" "scale_in_x3" {
  name                   = "scale-in-x3"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.video_downscaler_x3_asg.name
}

