terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
  backend "s3" {
    bucket = "mngmnt-terraform-state-dmorozov-01"
    key = "terraform/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "terraform-test-locks"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform-state-dmorozov-01" {
    bucket = "mngmnt-terraform-state-dmorozov-01"
    lifecycle {
        prevent_destroy = true
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform-state-dmorozov-01" {
  bucket = aws_s3_bucket.terraform-state-dmorozov-01.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "terraform-state-dmorozov-01" {
  bucket = aws_s3_bucket.terraform-state-dmorozov-01.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  hash_key = "LockID"
  name = "terraform-test-locks"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
      name = "LockID"
      type = "S"
  }
}