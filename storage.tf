resource "aws_s3_bucket" "S3-bucket" {
  bucket = "my-ha-webapp-project-bucket-ilia"
  tags = {
    name        = "HA webapp"
    Environment = "Prod"
  }
}

resource "aws_s3_bucket_public_access_block" "pub-block" {
  bucket = aws_s3_bucket.S3-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_server_side_encryption_configuration" "sse-conf" {
  bucket = aws_s3_bucket.S3-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
#Push simple text document to my s3 bucket.
resource "aws_s3_object" "app-info" {
  bucket = aws_s3_bucket.S3-bucket.id
  key    = "app-info.txt"
  source = "${path.module}/app-info.txt"
}