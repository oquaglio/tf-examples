variable "region" {}

variable "main_vpc_cidr" {}

variable "public_subnets" {}

variable "private_subnets" {}

variable "additional_tags" {
  type = map(string)
  default = {
    Project     = "tf-examples"
    Example     = "vpc-example-2"
    Environment = "dev"
    Owner       = "otto.q@gmx.com"
  }
}