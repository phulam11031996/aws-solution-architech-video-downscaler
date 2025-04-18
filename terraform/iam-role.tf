# SSM Role for EC2
resource "aws_iam_role" "ssm_role" {
  name = "EC2SSRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach SSM Managed Policy to Role
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance Profile for EC2 with SSM Role
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "EC2SSMProfile"
  role = aws_iam_role.ssm_role.name
}


# SSM + S3 Role for EC2
resource "aws_iam_role" "ssm_s3_role" {
  name = "EC2SSMAndS3Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach SSM Managed Policy to SSM+S3 Role
resource "aws_iam_role_policy_attachment" "ssm_s3_ssm_policy" {
  role       = aws_iam_role.ssm_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Custom Inline Policy for S3 Access
resource "aws_iam_role_policy" "ssm_s3_s3_policy" {
  name = "SSMS3BucketAccess"
  role = aws_iam_role.ssm_s3_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = "${aws_s3_bucket.video_scaler_bucket.arn}/*"
      }
    ]
  })
}

# Instance Profile for EC2 with SSM+S3 Role
resource "aws_iam_instance_profile" "ssm_s3_profile" {
  name = "EC2SSMAndS3Profile"
  role = aws_iam_role.ssm_s3_role.name
}

