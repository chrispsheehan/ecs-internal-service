include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  service_name = "ecs-internal-caller-svc"
  connection_type = "vpc_link"
}

inputs = {
  service_name = local.service_name
  connection_type = local.connection_type
}

terraform {
  source = "../../../../modules//aws//service"
}
