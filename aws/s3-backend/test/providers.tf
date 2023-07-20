provider "aws" {
  region = "ap-southeast-2"
}


terraform {

  # needs cli params
  #   backend "s3" {}

  # no cli params
  backend "s3" {
    bucket         = "tf-examples-terraform-state"
    key            = "path/to/your/terraform.tfstate"
    region         = "ap-southeast-2" # Replace with your desired AWS region
    dynamodb_table = "tf-examples-terraform-locks"
    encrypt        = false
  }

}
