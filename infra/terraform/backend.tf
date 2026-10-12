terraform {
  backend "s3" {
    bucket         = "harbourbooks-tfstate-dan"
    key            = "harbourbooks/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "harbourbooks-tfstate-lock"
    encrypt        = true
  }
}