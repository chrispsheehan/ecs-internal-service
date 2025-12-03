include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  service_name    = "ecs-internal-responder-svc"
  connection_type = "vpc_link"
  root_path       = "responder"
}

inputs = {
  service_name    = local.service_name
  connection_type = local.connection_type
  root_path       = local.root
}

terraform {
  source = "../../../../modules//aws//service"
}
