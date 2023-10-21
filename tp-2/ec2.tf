provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAVXFRXLW4CNW35E22"
  secret_key = "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"
}

resource "aws_instance" "my_ec2" {
  ami           = "ami-03eb6185d756497f8"
  instance_type = "t2.micro"
  key_name      = "devops-olivier"

  tags = {
    Name = "ec2-olivier"
  }

  root_block_device {
    delete_on_termination = true
  }

}

/*
resource "aws_eip" "lb" {
  vpc = true
}

output "eip" {
  value = aws_eip.lb
}

resource "aws_s3_bucket" "mys3" {
  bucket = "kplas-attribute-demo-001"
}

output "mys3bucket" {
  value = aws_s3_bucket.mys3
}
*/