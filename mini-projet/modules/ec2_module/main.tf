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

data "aws_ami" "app_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

resource "aws_instance" "my_ec2" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.generated_key.key_name

  tags = var.aws_common_tag

  //security_groups = ["${aws_security_group.allow_ssh_http_https.name}"]
  security_groups = ["${module.sg.output_sg_name}"]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install -y nginx",
      "sudo systemctl start nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      //private_key = file("../../.secret_credentials/devops-olivier.pem")
      private_key = tls_private_key.pem_ssh_key.private_key_pem
      host        = self.public_ip
    }
  }

  depends_on = [ module.sg ]

  root_block_device {
    delete_on_termination = true
  }

}
/*
resource "aws_eip" "lb" {
  instance = aws_instance.my_ec2.id
  domain   = "vpc"
  provisioner "local-exec" {
    command = "echo PUBLIC_IP: ${aws_eip.lb.public_ip} ; ID: ${aws_instance.my_ec2.id} ; AZ: ${aws_instance.my_ec2.availability_zone} >> ip_ec2.txt"
  }
}
*/
output "output_instance_id" {
  value = "${aws_instance.my_ec2.id}"
  description = "The instance ID"
}

output "output_availability_zone" {
  value = "${aws_instance.my_ec2.availability_zone}"
  description = "The availability zone"
}

module "sg" {
  source = "../security_group_module" 
}
