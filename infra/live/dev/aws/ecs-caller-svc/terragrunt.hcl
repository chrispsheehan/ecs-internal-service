include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  service_name    = "ecs-internal-caller-svc"
  connection_type = "vpc_link"
  service_path    = "caller"
}

inputs = {
  service_name    = local.service_name
  connection_type = local.connection_type
  service_path    = local.service_path
}

terraform {
  source = "../../../../modules//aws//service"
}
