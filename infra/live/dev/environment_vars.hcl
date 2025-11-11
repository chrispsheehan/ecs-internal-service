locals {
  deploy_branches       = ["*"]
  wait_for_steady_state = false
  local_tunnel          = true
}

inputs = {
  deploy_branches       = local.deploy_branches
  wait_for_steady_state = local.wait_for_steady_state
  local_tunnel          = local.local_tunnel
}
