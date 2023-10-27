output "output_ec2_instance" {
  value = aws_instance.my_ec2
}

output "output_ec2_id" {
  value = aws_instance.my_ec2.id
}

output "output_az" {
  value = aws_instance.my_ec2.availability_zone
}