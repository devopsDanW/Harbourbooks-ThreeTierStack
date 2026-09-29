resource "aws_security_group" "this" {
  name        = var.sg_name
  description = "Managed by the security_group module"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = length(ingress.value.cidr_blocks) > 0 ? ingress.value.cidr_blocks : null
      security_groups = ingress.value.source_security_group_id != null ? [ingress.value.source_security_group_id] : null
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = var.sg_name })
}