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

  security_groups = ["${aws_security_group.allow_http_https.name}"]

  root_block_device {
    delete_on_termination = true
  }

}

resource "aws_security_group" "allow_http_https" {
  name        = "olivier-sg"
  description = "Allow http and https inbound traffic"
  //vpc_id      = aws_vpc.main.id

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
}

resource "aws_eip" "lb" {
  instance = aws_instance.my_ec2.id
  domain   = "vpc"
}