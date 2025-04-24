# 1. SNS Topic
resource "aws_sns_topic" "video_scaler_topic" {
  name = "video-scaler-topic"
}

# 2. SQS Queues with 1-hour visibility timeout
resource "aws_sqs_queue" "video_x1_queue" {
  name                       = "video-x1-queue"
  visibility_timeout_seconds = 3600
}

resource "aws_sqs_queue" "video_x2_queue" {
  name                       = "video-x2-queue"
  visibility_timeout_seconds = 3600
}

resource "aws_sqs_queue" "video_x3_queue" {
  name                       = "video-x3-queue"
  visibility_timeout_seconds = 3600
}

# 3. Subscribe SQS queues to the SNS topic
resource "aws_sns_topic_subscription" "sub_1" {
  topic_arn = aws_sns_topic.video_scaler_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.video_x1_queue.arn
}

resource "aws_sns_topic_subscription" "sub_2" {
  topic_arn = aws_sns_topic.video_scaler_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.video_x2_queue.arn
}

resource "aws_sns_topic_subscription" "sub_3" {
  topic_arn = aws_sns_topic.video_scaler_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.video_x3_queue.arn
}

# 4. Allow SNS to publish to each SQS queue
resource "aws_sqs_queue_policy" "video_x1_queue_policy" {
  queue_url = aws_sqs_queue.video_x1_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "sns.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.video_x1_queue.arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = aws_sns_topic.video_scaler_topic.arn
        }
      }
    }]
  })
}

resource "aws_sqs_queue_policy" "video_x2_queue_policy" {
  queue_url = aws_sqs_queue.video_x2_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "sns.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.video_x2_queue.arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = aws_sns_topic.video_scaler_topic.arn
        }
      }
    }]
  })
}

resource "aws_sqs_queue_policy" "video_x3_queue_policy" {
  queue_url = aws_sqs_queue.video_x3_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "sns.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.video_x3_queue.arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = aws_sns_topic.video_scaler_topic.arn
        }
      }
    }]
  })
}
