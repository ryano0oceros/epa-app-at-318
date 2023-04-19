provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

data "aws_ami" "ubuntu-linux-2004" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "us-east-1"

  vpc_cidr = "10.24.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Example    = local.name
    GithubRepo = "epa-at-318-tf-aws-vpc"
    GithubOrg  = "ryano0oceros"
  }
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "git::https://github.com/ryano0oceros/epa-at-318-tf-aws-vpc"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]

  tags = local.tags
}

################################################################################
# Sample Instance
################################################################################

resource "aws_instance" "app_server" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

resource "aws_instance" "vm-server" {
  ami                    = data.aws_ami.ubuntu-linux-2004.id
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.private_subnets[0].id
  vpc_security_group_ids = [module.vpc.default_vpc_default_security_group_id.id]
  source_dest_check      = false
  
  tags = {
    Name = "epa-demo-server-vm"
  }
}