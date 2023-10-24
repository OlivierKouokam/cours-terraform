resource "aws_eip" "lb" {
  instance = module.ec2.output_instance_id
  domain   = "vpc"
  provisioner "local-exec" {
    command = "echo PUBLIC_IP: ${aws_eip.lb.public_ip} ; ID: ${module.ec2.output_instance_id} ; AZ: ${module.ec2.output_availability_zone} >> ip_ec2.txt"
  }
}

module "ec2" {
  source = "../ec2_module"
}
