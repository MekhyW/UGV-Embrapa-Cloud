resource "aws_s3_bucket" "rosbag_storage" {
  bucket = "${var.project_name}-rosbag-storage"
}

resource "aws_s3_bucket_versioning" "rosbag_versioning" {
  bucket = aws_s3_bucket.rosbag_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "rosbag_lifecycle" {
  bucket = aws_s3_bucket.rosbag_storage.id

  rule {
    id     = "archive"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }
  }
}
