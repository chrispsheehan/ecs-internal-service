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

  xray_interface_endpoints = var.xray_enabled ? {
    xray = "xray"
  } : {}

  interface_endpoints = merge(
    local.base_interface_endpoints,
    local.tunnel_interface_endpoints,
    local.xray_interface_endpoints
  )

  private_dns_overrides = {
    xray = false
  }
}