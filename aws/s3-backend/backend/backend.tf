provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_s3_bucket" "tf_examples_terraform_state" {
  bucket = "tf-examples-terraform-state"

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }
}


resource "aws_dynamodb_table" "tf_examples_terraform_locks" {
  name         = "tf-examples-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
