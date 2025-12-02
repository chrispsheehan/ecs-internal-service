locals {
  priority = tonumber(substr(md5(var.service_name), 0, 2)) % 90 + 10

  full_tg_name      = "${var.service_name}-tg"
  target_group_name = length(local.full_tg_name) > 32 ? substr(local.full_tg_name, 0, 32) : local.full_tg_name

  is_root_path = var.service_path == "/"

  target_group_arn = local.is_root_path ? var.default_target_group_arn : aws_lb_target_group.service_target_group[0].arn
}
