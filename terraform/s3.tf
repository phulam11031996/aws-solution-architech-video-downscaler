# Create an S3 bucket for storing video files
resource "aws_s3_bucket" "video_scaler_bucket" {
  bucket = "video-scaler-bucket-phulam1103"
}

# IAM Policy attachment
resource "aws_iam_role_policy" "s3_policy" {
  name = "s3-access"
  role = aws_iam_role.ssm_s3_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ],
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.video_scaler_bucket.arn}/*"
      }
    ]
  })
}
