variable "project_name" {
  type = string
}

variable "task_name" {
  type = string
}

variable "ecs_name" {
  type = string
}

variable "initial_task_count" {
  type = number
}

variable "max_scaled_task_count" {
  type = number
}

variable "scaling_strategy" {
  type = object({
    mode = string                        # "cpu", "sqs", "cpu_and_sqs"

    cpu = object({
      scale_out_threshold = number       # CPU >= this → scale out
      scale_in_threshold  = number       # CPU <= this → scale in
      scale_out_adjustment = number
      scale_in_adjustment  = number
      cooldown_out = number
      cooldown_in  = number
    })

    sqs = object({
      scale_out_threshold = number       # queue length >= this → scale out
      scale_in_threshold  = number       # queue length <= this → scale in
      scale_out_adjustment = number
      scale_in_adjustment  = number
      cooldown_out = number
      cooldown_in  = number
      queue_name   = string
    })
  })

  validation {
    condition = contains(["cpu", "sqs", "cpu_and_sqs"], var.scaling_strategy.mode)
    error_message = "scaling_strategy.mode must be one of: cpu, sqs, cpu_and_sqs."
  }
}
