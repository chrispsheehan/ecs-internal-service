data "terraform_remote_state" "security" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = "${var.environment}/aws/security/terraform.tfstate"
    region = var.aws_region
  }
}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["vpc"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

data "aws_route_tables" "subnet_route_tables" {
  filter {
    name   = "association.subnet-id"
    values = data.aws_subnets.private.ids
  }
}
