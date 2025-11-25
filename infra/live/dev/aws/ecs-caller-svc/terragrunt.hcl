include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  service_name = "ecs-internal-caller-svc"
}

terraform {
  source = "../../../../modules//aws//ecs"
}
