##############################################
# Define your VPC and subnets
##############################################

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   ="${local.vpc_name}"
  cidr   = "${local.cidr_block}"

  azs             = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  database_subnets    = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
  create_igw = true
}


resource "aws_internet_gateway" "gw" {
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "dev"
  }
}

