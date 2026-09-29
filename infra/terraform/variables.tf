variable "region" {
  type    = string
  default = "ap-southeast-2"
}

variable "vpc_cidr" {
  type    = string
  default = "10.2.0.0/16"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "name_prefix" {
  type    = string
  default = "harbour-books-tf"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.2.1.0/24"
}

variable "public_subnet_cidr_b" {
  type    = string
  default = "10.2.4.0/24"
}

variable "my_ip" {
  description = "your IP for web_sg inbound rule"
  type        = string
}

variable "web_instances" {
  description = "Map for_each on ec2_instance module"
  type = map(object({
    instance_type = string
  }))
}

variable "private_subnet_cidr_a" {
  type    = string
  default = "10.2.2.0/24"
}

variable "private_subnet_cidr_b" {
  type    = string
  default = "10.2.3.0/24"
}

variable "db_name" {
  type    = string
  default = "harbourbooks"
}

variable "db_username" {
  type    = string
  default = "appuser"
}
