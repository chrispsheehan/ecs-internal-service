variable "cluster_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "initial_task_count" {
  type = number
}

variable "scaling_strategy" {
  type = object({
    max_scaled_task_count = optional(number)
    cpu = optional(object({
      scale_out_threshold  = number
      scale_in_threshold   = number
      scale_out_adjustment = number
      scale_in_adjustment  = number
      cooldown_out         = number
      cooldown_in          = number
    }))
    sqs = optional(object({
      scale_out_threshold  = number
      scale_in_threshold   = number
      scale_out_adjustment = number
      scale_in_adjustment  = number
      cooldown_out         = number
      cooldown_in          = number
      queue_name           = string
    }))
  })

  # {} = "off" by convention
  default = {}

  validation {
    condition = !(
      try(var.scaling_strategy.cpu != null, false) &&
      try(var.scaling_strategy.sqs != null, false)
    )
    error_message = "Only one of scaling_strategy.cpu or scaling_strategy.sqs may be set at a time to avoid conflicting autoscalers."
  }
}