variable "ami_id" {
  description = "AMI ID for the instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet to launch the instance in"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "Security group IDs to attach"
  type        = list(string)
}

variable "instance_name" {
  description = "Name tag for the instance"
  type        = string
}

variable "associated_public_ip_address" {
  description = "whether to assign a public IP (only relevant in a public subnet)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "tags apply to the instance"
  type        = map(string)
  default     = {}
}

variable "user_data" {
  description = "User data script to run on instance launch"
  type = string
  default = null
}