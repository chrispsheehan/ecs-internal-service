include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  service_name = "ecs-internal-responder-svc"
  python_app   = "app.responder.app:app"
}

inputs = {
  service_name = local.service_name
  python_app   = local.python_app
}

terraform {
  source = "../../../../modules//aws//task"
}
