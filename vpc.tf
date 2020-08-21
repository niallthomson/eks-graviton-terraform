locals {
  private_subnets    = [for i, n in var.availability_zones : cidrsubnet(var.vpc_cidr, 4, i)]
  public_seed_cidr   = cidrsubnet(var.vpc_cidr, 4, length(var.availability_zones))
  public_subnets     = [for i, n in var.availability_zones : cidrsubnet(local.public_seed_cidr, 2, i)]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.21.0"
  name    = "${var.environment_name}-vpc"
  azs     = var.availability_zones
  cidr    = var.vpc_cidr

  private_subnets              = local.private_subnets
  public_subnets               = local.public_subnets
  enable_dns_hostnames         = true
  enable_dns_support           = true
  enable_nat_gateway           = true
  single_nat_gateway           = true
  one_nat_gateway_per_az       = false
  public_dedicated_network_acl = true

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  tags = merge(
    var.tags,
    {
      "kubernetes.io/cluster/${var.environment_name}" = "shared"
    },
  )
}

resource "aws_network_acl" "main" {
  count = length(var.availability_zones)

  vpc_id     = module.vpc.vpc_id
  subnet_ids = [module.vpc.private_subnets[count.index]]

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.environment_name}-private-${count.index}"
  }
}

resource "aws_security_group" "dummy" {
  name        = "${var.environment_name}-dummy-sg"
  description = "Allow SSH access to provisioner host and outbound internet access"
  vpc_id      = module.vpc.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}