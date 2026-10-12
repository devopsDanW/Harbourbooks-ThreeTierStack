variable "alb_name" {
  description = "Name prefix for ALB resources"
  type        = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "subnets_ids" {
  description = "List of subnet IDs for ALB, at least 2 AZs"
  type        = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vpc_id" {
  type = string
}

variable "health_check_path" {
  type    = string
  default = "/health"
}