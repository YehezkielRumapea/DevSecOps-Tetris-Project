terraform {
  backend "s3" {
    bucket = "kiel-bucket1"
    region = "us-east-1"
    key = "Tetris_App/Jenkins-server/terraform.tfstate"
    encrypt = true
    use_lockfile = true
  }
  required_version = ">=1.13.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.23.0"
    }
  }
}