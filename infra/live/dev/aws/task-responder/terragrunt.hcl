include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  service_name   = "ecs-internal-responder-svc"
}

inputs = {
  service_name = local.service_name
}

terraform {
  source = "../../../../modules//aws//task"
}
