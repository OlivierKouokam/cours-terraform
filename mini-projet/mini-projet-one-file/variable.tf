variable "ebs_size" {
  type        = number
  description = "set ebs size"
  default     = 8
}

variable "key_name" {
  type    = string
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

variable "sg_name" {
  type        = string
  description = "set sg name"
  default     = "miniprojet_olivier_sg"
}