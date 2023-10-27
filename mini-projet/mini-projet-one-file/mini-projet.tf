provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAVXFRXLW4CNW35E22"
  secret_key = "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"
}

terraform {
  backend "s3" {
    bucket     = "terraform-backend-olivier"
    key        = "olivier-miniprojet.tfstate"
    region     = "us-east-1"
    access_key = "AKIAVXFRXLW4CNW35E22"
    secret_key = "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"
  }
}
/*
resource "tls_private_key" "pem_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.pem_ssh_key.public_key_openssh
}

output "private_key" {
  value     = tls_private_key.pem_ssh_key.private_key_pem
  sensitive = true
}
*/
data "aws_ami" "app_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

resource "aws_instance" "my_ec2" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type
  availability_zone = "us-east-1a"

  //key_name      = aws_key_pair.generated_key.key_name
  key_name = var.key_name

  tags = var.aws_common_tag

  security_groups = ["${aws_security_group.allow_ssh_http_https.name}"]
  //security_groups = ["${module.sg.output_sg_name}"]

  //ebs_block_device [ {module.ebs.output_instance_id}]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install -y nginx",
      "sudo systemctl start nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("./.secret_credentials/devops-olivier.pem")
      //private_key = tls_private_key.pem_ssh_key.public_key_pem
      host = self.public_ip
    }
  }

  depends_on = [/*resource.tls_private_key.pem_ssh_key,
    resource.aws_key_pair.generated_key,*/
    resource.aws_ebs_volume.my_volume,
  resource.aws_security_group.allow_ssh_http_https]

  root_block_device {
    delete_on_termination = true
  }

}

resource "aws_security_group" "allow_ssh_http_https" {
  name        = var.sg_name
  description = "Allow SSH, http and https inbound traffic and outbound traffic"

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

resource "aws_ebs_volume" "my_volume" {
  availability_zone = "us-east-1a"
  size              = var.ebs_size

  tags = {
    Name = "ebs_miniprojet"
  }
}

resource "aws_eip" "lb" {
  //instance = aws_instance.my_ec2.id
  domain   = "vpc"
  provisioner "local-exec" {
    command = "echo PUBLIC_IP: ${aws_eip.lb.public_ip} ; ID: ${aws_instance.my_ec2.id} ; AZ: ${aws_instance.my_ec2.availability_zone} >> ip_ec2.txt"
  }
  depends_on = [resource.aws_instance.my_ec2]
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.my_volume.id
  instance_id = aws_instance.my_ec2.id
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.my_ec2.id
  allocation_id = aws_eip.lb.id
}