
# resource "tls_private_key" "pem_ssh_key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "aws_key_pair" "generated_key" {
#   key_name   = var.key_name
#   public_key = tls_private_key.pem_ssh_key.public_key_openssh
# }

# output "private_key" {
#   value     = tls_private_key.pem_ssh_key.private_key_pem
#   sensitive = true
# }

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
  availability_zone = var.my_az
  
  key_name = var.key_name

  tags = var.aws_common_tag

  security_groups = ["${var.sg_name}"]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y nginx",
      "sudo systemctl start nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("C:/Users/OK_MEDIA/Documents/TP/cours-terraform/mini-projet/.secret_credentials/devops-olivier.pem")
      host        = self.public_ip
    }
  }

  root_block_device {
    delete_on_termination = true
  }

}