provider "aws" {
  region     = "us-east-1"
  access_key = "****"
  secret_key = "********"
}

terraform {
  backend "s3" {
    bucket     = "terraform-backend-olivier"
    key        = "olivier-prod.tfstate"
    region     = "us-east-1"
    access_key = "****"
    secret_key = "********"
  }
}

module "ec2" {
  source = "../modules/ec2module"
  instance_type = "t2.micro"
  sg_name = "prod-olivier-sg"
    aws_common_tag = {
        Name : "ec2-prod-olivier"
    }
}