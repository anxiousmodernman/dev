
provider "aws" {
  profile = "${var.aws_profile}"
  region = "us-west-2"
}

data "aws_availability_zones" "available" {}

# We are sourcing a public module from the internet
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "aweg-dev"

  cidr            = "10.0.0.0/16"
  # take the first two availability zones
  azs             = "${slice(data.aws_availability_zones.available.names,0,2)}"

  public_subnets  = ["10.0.1.0/24"]
  private_subnets = ["10.0.2.0/24"]

  enable_nat_gateway = true

  create_database_subnet_group = false

}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}
