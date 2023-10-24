variable "key_name" {
  type = string
  default = "devops-olivieraws"
}

variable "instance_type" {
  type        = string
  description = "set aws instance type"
  default     = "t3.micro"
}

variable "aws_common_tag" {
  type        = map(any)
  description = "set aws tag"
  default = {
    Name = "ec2-mini-projet"
  }
}