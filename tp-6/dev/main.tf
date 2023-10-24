provider "aws" {
  region     = "us-east-1"
  access_key = "****"
  secret_key = "********"
}

terraform {
  backend "s3" {
    bucket     = "terraform-backend-olivier"
    key        = "olivier-dev.tfstate"
    region     = "us-east-1"
    access_key = "****"
    secret_key = "********"
  }
}

module "ec2" {
  source = "../modules/ec2module"
  instance_type = "t3.micro"
  sg_name = "dev-olivier-sg"
    aws_common_tag = {
        Name : "ec2-dev-olivier"
    }
}