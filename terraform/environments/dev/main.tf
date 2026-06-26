data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

locals {
  # Choose the first available subnet from the default VPC list
  subnet_id = tolist(data.aws_subnets.default.ids)[0]
}

module "security_groups" {
  source      = "../../modules/security_groups"
  vpc_id      = data.aws_vpc.default.id
  environment = var.environment
  tags        = var.tags
}

module "ec2" {
  source             = "../../modules/ec2"
  subnet_id          = local.subnet_id
  security_group_ids = [module.security_groups.security_group_id]
  instance_type      = var.instance_type
  key_name           = var.key_name
  environment        = var.environment
  tags               = var.tags
}
