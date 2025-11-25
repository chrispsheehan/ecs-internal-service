include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  service_name = "ecs-internal-responder-svc"
}

terraform {
  source = "../../../../modules//aws//ecs"
}
