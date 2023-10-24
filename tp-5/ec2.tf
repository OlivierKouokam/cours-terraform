provider "aws" {
  region     = "us-east-1"
  access_key = "****"
  secret_key = "********"
}

data "aws_ami" "app_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "my_ec2" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type
  key_name      = "devops-olivier"

  tags = var.aws_common_tag

  security_groups = ["${aws_security_group.allow_ssh_http_https.name}"]

  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install -y nginx1.12",
      "sudo systemctl start nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("./devops-olivier.pem")
      host        = self.public_ip
    }
  }

  root_block_device {
    delete_on_termination = true
  }

}

resource "aws_security_group" "allow_ssh_http_https" {
  name        = "olivier-sg"
  description = "Allow SSH, http and https inbound traffic"

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "lb" {
  instance = aws_instance.my_ec2.id
  domain   = "vpc"
  provisioner "local-exec" {
    command = "echo PUBLIC_IP: ${aws_eip.lb.public_ip} ; ID: ${aws_instance.my_ec2.id} ; AZ: ${aws_instance.my_ec2.availability_zone} >> infos_ec2.txt"
  }
}

terraform {
  backend "s3" {
    bucket     = "terraform-backend-olivier"
    key        = "terraform.tfstate"
    region     = "us-east-1"
    access_key = "****"
    secret_key = "********"
  }
}