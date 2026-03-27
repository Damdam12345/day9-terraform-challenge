terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get subnets in the VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "web_cluster" {
  source = "github.com/Damdam12345/day9-terraform-challenge//modules/services/webserver-cluster?ref=v0.0.1"
  cluster_name  = "prod-cluster"
  ami_id        = "ami-09d0c9a85bf1b9ea7"
  instance_type = "t3.micro"
  server_port = 80

  # Use data sources
  vpc_id    = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.default.ids

  min_size         = 2
  max_size         = 4

  tags = {
    Environment = "prod"
  }
}
output "alb_dns_name" {
  value = module.web_cluster.alb_dns_name
}