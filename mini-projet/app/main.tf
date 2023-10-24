provider "aws" {
  region     = "us-east-1"
  access_key = "****"
  secret_key = "********"
}

terraform {
  backend "s3" {
    bucket     = "terraform-backend-olivier"
    key        = "olivier-miniprojet.tfstate"
    region     = "us-east-1"
    access_key = "****"
    secret_key = "********"
  }
}
/*
module "ec2" {
  source = "../modules/ec2_module"
}
*/
module "ebs" {
  source = "../modules/ebs_module"
}

module "public_ip" {
  source = "../modules/public_ip_module"
}