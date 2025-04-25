# Create an S3 bucket for storing video files
resource "aws_s3_bucket" "video_scaler_bucket" {
  bucket = "video-scaler-bucket-phulam1103"
}

resource "aws_s3_bucket_cors_configuration" "video_scaler_bucket_cors" {
  bucket = aws_s3_bucket.video_scaler_bucket.id

  cors_rule {
    allowed_methods = ["GET", "PUT", "POST", "HEAD"]
    allowed_headers = ["*"]
    allowed_origins = ["*"] # Consider limiting this for security
  }
}

# Enable lifecycle configuration for the S3 bucket
resource "aws_s3_bucket_lifecycle_configuration" "video_scaler_lifecycle" {
  bucket = aws_s3_bucket.video_scaler_bucket.id

  rule {
    id     = "archive-and-delete"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "DEEP_ARCHIVE"
    }

    expiration {
      days = 90
    }

    filter {
      prefix = ""
    }
  }
}

