terraform {
  backend "s3" {
    bucket = "kiel-bucket"
    region = "us-east-1"
    key = "kiel-project"
    use_lock_file = true
    encrypt = true
  }
  required_version = ">=1.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.49.0"
    }
  }
}