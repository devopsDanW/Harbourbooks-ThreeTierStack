region                = "ap-southeast-2"
name_prefix           = "harbour-books-staging"
vpc_cidr              = "10.3.0.0/16"
public_subnet_cidr    = "10.3.1.0/24"
public_subnet_cidr_b  = "10.3.4.0/24"
private_subnet_cidr_a = "10.3.2.0/24"
private_subnet_cidr_b = "10.3.3.0/24"
# NOTE: replace with your own public IP before running terraform plan/apply
my_ip = "203.0.113.1"
web_instances = {
  "web-1" = { instance_type = "t3.small" }
  "web-2" = { instance_type = "t3.small" }
}
tags = {
  Environment = "staging"
}