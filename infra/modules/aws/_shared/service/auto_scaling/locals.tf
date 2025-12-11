locals {
  enable_cpu_scaling = var.scaling_strategy.mode == "cpu" || var.scaling_strategy.mode == "cpu_and_sqs"

  evaluation_periods_cpu_out = local.enable_cpu_scaling ? (
    var.scaling_strategy.cpu.cooldown_out <= 60 ? 1 : floor(var.scaling_strategy.cpu.cooldown_out / 60)
  ) : null

  evaluation_periods_cpu_in = local.enable_cpu_scaling ? (
    var.scaling_strategy.cpu.cooldown_in <= 60 ? 1 : floor(var.scaling_strategy.cpu.cooldown_in / 60)
  ) : null

  enable_sqs_scaling = var.scaling_strategy.mode == "sqs" || var.scaling_strategy.mode == "cpu_and_sqs"

  evaluation_periods_sqs_out = local.enable_sqs_scaling ? (
    var.scaling_strategy.sqs.cooldown_out <= 60 ? 1 : floor(var.scaling_strategy.sqs.cooldown_out / 60)
  ) : null

  evaluation_periods_sqs_in = local.enable_sqs_scaling ? (
    var.scaling_strategy.sqs.cooldown_in <= 60 ? 1 : floor(var.scaling_strategy.sqs.cooldown_in / 60)
  ) : null
}
