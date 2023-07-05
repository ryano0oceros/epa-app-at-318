provider "aws" {
  region    = local.region
  access_key= "${{ secrets.AWS_ACCESS_KEY_ID }}"
  secret_key= "${{ secrets.AWS_SECRET_ACCESS_KEY }}"
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "us-east-1"

  vpc_cidr = "10.24.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Example    = local.name
    GithubRepo = "ryano0oceros-at-318-tf-aws-vpc"
    GithubOrg  = "ryano0oceros"
  }
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "git::https://github.com/ryano0oceros/ryano0oceros-at-318-tf-aws-vpc?ref=e1f1033"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]

  tags = local.tags
}
