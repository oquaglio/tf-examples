resource "aws_s3_bucket" "tf_examples_test_bucket" {
  bucket = "tf-examples-test-bucket"

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = false
  }
}