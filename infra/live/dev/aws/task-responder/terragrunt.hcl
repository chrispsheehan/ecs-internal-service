include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  service_name = "ecs-internal-responder-svc"
  python_app   = "app.responder.app:app"
  root_path    = "responder"
}

inputs = {
  service_name = local.service_name
  python_app   = local.python_app
  root_path    = local.root_path
}

terraform {
  source = "../../../../modules//aws//task"
}
