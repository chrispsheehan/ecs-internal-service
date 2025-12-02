locals {
  priority = tonumber(substr(md5(var.service_name), 0, 2)) % 90 + 10

  full_tg_name = "${var.service_name}-tg"
  target_group_name = length(local.full_tg_name) > 32 ? substr(local.full_tg_name, 0, 32) : local.full_tg_name
}
