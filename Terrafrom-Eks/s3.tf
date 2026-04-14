terraform {
  backend "s3" {
    bucket = "kiel-bucket1"
    region = "us-east-1"
    key = "kiel-project"
    use_lockfile = true
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