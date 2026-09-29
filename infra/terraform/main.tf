terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags       = merge(var.tags, { Name = "${var.name_prefix}-vpc" })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.name_prefix}-igw" })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { Name = "${var.name_prefix}-public" })
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr_b
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { Name = "${var.name_prefix}-public-b" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = merge(var.tags, { Name = "${var.name_prefix}-public-rt" })
}


resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table_association.public.id
}

resource "aws_subnet" "private_a" {
  vpc_id     = aws_vpc.this.id
  cidr_block = var.private_subnet_cidr_a
  tags       = merge(var.tags, { Name = "${var.name_prefix}-private" })
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr_b
  availability_zone = data.aws_availability_zones.available.names[1]
  tags              = merge(var.tags, { Name = "${var.name_prefix}-private" })
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  tags       = merge(var.tags, { Name = "${var.name_prefix}-db-subnet-group" })
}

resource "aws_db_instance" "this" {
  identifier                  = "${var.name_prefix}-rds"
  engine                      = "mysql"
  instance_class              = "db.t3.micro"
  allocated_storage           = 20
  db_name                     = var.db_name
  username                    = var.db_username
  manage_master_user_password = true
  db_subnet_group_name        = aws_db_subnet_group.this.name
  vpc_security_group_ids      = [module.db_sg.sg_id]
  skip_final_snapshot         = true
  tags                        = merge(var.tags, { Name = "${var.name_prefix}-db-subnet-group" })
}



module "web_sg" {
  source  = "./modules/security_group"
  sg_name = "${var.name_prefix}-web-sg"
  vpc_id  = aws_vpc.this.id
  ingress_rules = [
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      source_security_group_id = module.alb_sg.sg_id
    }
  ]
  tags = var.tags
}

module "db_sg" {
  source  = "./modules/security_group"
  sg_name = "${var.name_prefix}-db-sg"
  vpc_id  = aws_vpc.this.id
  ingress_rules = [
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      source_security_group_id = module.web_sg.sg_id
    }
  ]
  tags = var.tags
}

module "alb_sg" {
  source  = "./modules/security_group"
  sg_name = "${var.name_prefix}-alb-sg"
  vpc_id  = aws_vpc.this.id
  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["${var.my_ip}/32"]
    }
  ]
  tags = var.tags
}


module "web_instances" {
  source                       = "./modules/ec2_instance"
  for_each                     = var.web_instances
  instance_name                = "${var.name_prefix}-${each.key}"
  ami_id                       = data.aws_ssm_parameter.al2023_ami.value
  instance_type                = each.value.instance_type
  subnet_id                    = aws_subnet.public.id
  vpc_security_group_ids       = [module.web_sg.sg_id]
  associated_public_ip_address = true
  tags                         = var.tags
}

module "alb" {
  source             = "./modules/alb"
  alb_name           = "${var.name_prefix}-alb"
  security_group_ids = [module.alb_sg.sg_id]
  subnets_ids        = [aws_subnet.public.id, aws_subnet.public_b.id]
  vpc_id             = aws_vpc.this.id
  tags               = var.tags
  health_check_path  = "/"
}

resource "aws_lb_target_group_attachment" "web_attach" {
  for_each         = var.web_instances
  target_group_arn = module.alb.target_group_arn
  target_id        = module.web_instances[each.key].instance_id
  port             = 80
}