provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAVXFRXLW4CNW35E22"
  secret_key = "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"
}

terraform {
  backend "s3" {
    bucket     = "terraform-backend-olivier"
    key        = "olivier-dev.tfstate"
    region     = "us-east-1"
    access_key = "AKIAVXFRXLW4CNW35E22"
    secret_key = "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"
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