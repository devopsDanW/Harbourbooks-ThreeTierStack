variable "sg_name" {
  description = "Name of the Security Group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID the security group belongs to"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules for this security group"
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string), [])
    source_security_group_id = optional(string, null)
  }))
  default = []
}

variable "tags" {
    description = "Tags to apply to the security group"
    type        = map(string)
    default     = {}
  }


