provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["../.secret_credentials/aws_credentials"]
}

terraform {
  backend "s3" {
    bucket                   = "terraform-backend-olivier"
    key                      = "olivier-miniprojet.tfstate"
    region                   = "us-east-1"
    shared_credentials_files = ["../.secret_credentials/aws_credentials"]
  }
}

module "sg" {
  source  = "../modules/security_group_module"
  sg_name = "allow_ssh_http_https_traffic"
}

module "ebs" {
  source   = "../modules/ebs_module"
  AZ       = module.ec2.output_az
  ebs_size = 16
}

module "public_ip" {
  source = "../modules/public_ip_module"
}

module "ec2" {
  source        = "../modules/ec2_module"
  instance_type = "t2.micro"
  //public_ip     = module.eip.output_eip
  sg_name = module.sg.output_sg_name
  aws_common_tag = {
    Name = "ec2-mini-projet-23-10-2023"
  }
}

resource "aws_volume_attachment" "mount_volume_to_ec2" {
  device_name = "/dev/sdh"
  volume_id   = module.ebs.output_ebs_id
  instance_id = module.ec2.output_ec2_id
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = module.ec2.output_ec2_id
  allocation_id = module.public_ip.output_eip_id
}

resource "null_resource" "export_datas" {
  provisioner "local-exec" {
    command = "echo PUBLIC_IP: ${module.public_ip.output_eip} ; INSTANCE_ID: ${module.ec2.output_ec2_instance.id} ; AZ: ${module.ec2.output_az} >> ip_ec2.txt"
  }
}