resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.vpc_security_group_ids
  associate_public_ip_address = var.associated_public_ip_address
  user_data = var.user_data

  tags = (merge(var.tags, { Name = var.instance_name }))
}