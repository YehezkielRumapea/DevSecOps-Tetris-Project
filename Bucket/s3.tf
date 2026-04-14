resource "aws_s3_bucket" "Tetris_App_Bucket" {
  bucket = "kiel-bucket1"
}

resource "aws_s3_bucket_versioning" "Tetris_App_Bucket_Versioning" {
  bucket = aws_s3_bucket.Tetris_App_Bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}