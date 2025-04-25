
resource "aws_cloudwatch_metric_alarm" "video_x1_queue_high" {
  alarm_name          = "video-x1-queue-too-many-messages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Average"
  threshold           = 5
  alarm_description   = "Trigger if video-x1-queue has more than 5 messages"
  dimensions = {
    QueueName = aws_sqs_queue.video_x1_queue.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_out_x1.arn]
}

resource "aws_cloudwatch_metric_alarm" "video_x1_queue_low" {
  alarm_name          = "video-x1-queue-idle"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "Scale in if queue is mostly empty"
  dimensions = {
    QueueName = aws_sqs_queue.video_x1_queue.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_in_x1.arn]
}

resource "aws_cloudwatch_metric_alarm" "x2_queue_high" {
  alarm_name          = "x2-queue-too-many-messages"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Average"
  threshold           = 5

  dimensions = {
    QueueName = aws_sqs_queue.video_x2_queue.name
  }

  alarm_description = "Scale out when queue has >= 5 messages"
  alarm_actions     = [aws_autoscaling_policy.scale_out_x2.arn]
}

resource "aws_cloudwatch_metric_alarm" "x2_queue_low" {
  alarm_name          = "x2-queue-few-messages"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Average"
  threshold           = 2

  dimensions = {
    QueueName = aws_sqs_queue.video_x2_queue.name
  }

  alarm_description = "Scale in when queue has <= 2 messages"
  alarm_actions     = [aws_autoscaling_policy.scale_in_x2.arn]
}

resource "aws_cloudwatch_metric_alarm" "x3_queue_high" {
  alarm_name          = "x3-queue-too-many-messages"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Average"
  threshold           = 5

  dimensions = {
    QueueName = aws_sqs_queue.video_x3_queue.name
  }

  alarm_description = "Scale out when queue has >= 5 messages"
  alarm_actions     = [aws_autoscaling_policy.scale_out_x3.arn]
}

resource "aws_cloudwatch_metric_alarm" "x3_queue_low" {
  alarm_name          = "x3-queue-few-messages"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Average"
  threshold           = 2

  dimensions = {
    QueueName = aws_sqs_queue.video_x3_queue.name
  }

  alarm_description = "Scale in when queue has <= 2 messages"
  alarm_actions     = [aws_autoscaling_policy.scale_in_x3.arn]
}
