# Define the AWS provider
provider "aws" {
  region = "ap-southeast-2"
}

# Create an instance launch configuration
resource "aws_launch_configuration" "asg_example_1" {
  name_prefix     = "asg-example-1"
  image_id        = "ami-02f0d7bd6acb31e1f"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.asg_example_1.id]
  key_name        = "asg-example-1-key"
  user_data       = <<-EOF
              #!/bin/bash
              echo "Hello, world!"
              EOF
}

# Create an Auto Scaling Group
resource "aws_autoscaling_group" "asg_example_1" {
  name                      = "asg-example-1"
  launch_configuration      = aws_launch_configuration.asg_example_1.name
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 1
  vpc_zone_identifier       = [aws_subnet.asg_example_1.id]
  health_check_type         = "EC2"
  health_check_grace_period = 300
  termination_policies      = ["OldestInstance"]
  # tag = [
  #   {
  #     "key" = "name"
  #     "value" = "robotr"
  #     "propagate_at_launch" = true
  #   },
  #   {
  #     "key" = "title"
  #     "value" = "engineer"
  #     "propagate_at_launch" = true
  #   }
  # ]
  # tag = {
  #   "key" = "name"
  #   "value" = "robotr"
  #   "propagate_at_launch" = true
  # }
}

# Create a security group to allow SSH access
resource "aws_security_group" "asg_example_1" {
  name_prefix = "asg-example-1"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a subnet for the Auto Scaling Group instances
resource "aws_subnet" "asg_example_1" {
  vpc_id            = aws_vpc.asg_example_1.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-southeast-2"
  tags              = var.custom_tags
}

# Create VPC
resource "aws_vpc" "asg_example_1" {
  cidr_block = "10.0.0.0/16"
}


variable "custom_tags" {
  type = map(string)

  default = {
    "name" = "asg-example-1", "layer" = "raw"
  }
}