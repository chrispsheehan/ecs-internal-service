locals {
  base_interface_endpoints = {
    ecr_api = "ecr.api"
    ecr_dkr = "ecr.dkr"
    logs    = "logs"
    xray    = "xray"
  }

  tunnel_interface_endpoints = var.local_tunnel ? {
    ssmmessages = "ssmmessages"
    ec2messages = "ec2messages"
  } : {}

  interface_endpoints = merge(
    local.base_interface_endpoints,
    local.tunnel_interface_endpoints
  )
}