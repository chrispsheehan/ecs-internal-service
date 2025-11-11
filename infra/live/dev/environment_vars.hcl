locals {
  deploy_branches = ["*"]
  local_tunnel    = true
}

inputs = {
  deploy_branches = local.deploy_branches
  local_tunnel    = local.local_tunnel
}
