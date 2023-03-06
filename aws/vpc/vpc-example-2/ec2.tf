resource "aws_instance" "private_instance" {
  ami           = "ami-03f7ef21b8063195c" #Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type
  instance_type = "t4g.nano"
  subnet_id     = aws_subnet.privatesubnets.id
  count         = var.create_instances ? 1 : 0 # create 1 instance if instance creation is enabled

  tags = merge(
    var.additional_tags,
    {
      Name = format("%s-%s-%s-%s", var.additional_tags.Project, var.additional_tags.Example, "private-instance-${count.index + 1}", var.additional_tags.Environment)
      Type = "t4g.nano"
    }
  )

}



resource "aws_instance" "public_instance" {
  ami           = "ami-03f7ef21b8063195c" #Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type
  instance_type = "t4g.nano"
  subnet_id     = aws_subnet.publicsubnets.id
  count         = var.create_instances ? 1 : 0 # create 1 instance if instance creation is enabled

  vpc_security_group_ids = [aws_security_group.example_sg.id]

  # allow SSH using PEM
  #   connection {
  #     type        = "ssh"
  #     user        = "ubuntu"
  #     private_key = file("~/.ssh/mykey.pem")
  #     timeout     = "2m"
  #     host        = self.public_ip
  #   }

  # allow SSH using ed25519
  # ssh-keygen -t ed25519 -f ~/.ssh/ec2key_ed25519
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/ec2key_ed25519")
    timeout     = "2m"
    host        = self.public_ip

    # # Use ed25519 SSH key for authentication
    # ssh_key = {
    #   algorithm  = "ED25519"
    #   public_key = file("~/.ssh/ec2key_ed25519.pub")
    # }
  }



  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apache2",
      "echo 'Hello, World!' | sudo tee /var/www/html/index.html"
    ]
  }

  tags = merge(
    var.additional_tags,
    {
      Name = format("%s-%s-%s-%s", var.additional_tags.Project, var.additional_tags.Example, "public-instance-${count.index + 1}", var.additional_tags.Environment)
      Type = "t4g.nano"
    }
  )

}

# SG to allow access to our public EC2 instance
resource "aws_security_group" "example_sg" {
  name_prefix = "example-sg"
  description = "Example security group"
  vpc_id      = aws_vpc.Main.id


  # allows inbound traffic on port 22 (SSH) and port 80 (HTTP) from any IP address
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}