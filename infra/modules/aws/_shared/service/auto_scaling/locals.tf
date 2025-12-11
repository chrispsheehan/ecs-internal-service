locals {
  evaluation_periods_out = var.auto_scale_cool_down_period_out <= 60 ? 1 : var.auto_scale_cool_down_period_out / 60
  evaluation_periods_in  = var.auto_scale_cool_down_period_in <= 60 ? 1 : var.auto_scale_cool_down_period_in / 60
}
