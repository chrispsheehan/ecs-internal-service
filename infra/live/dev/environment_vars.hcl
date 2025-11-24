locals {
  deploy_branches       = ["*"]
  wait_for_steady_state = true
  local_tunnel          = true
  xray_enabled          = true
}

inputs = {
  deploy_branches       = local.deploy_branches
  wait_for_steady_state = local.wait_for_steady_state
  local_tunnel          = local.local_tunnel
  xray_enabled          = local.xray_enabled
}
