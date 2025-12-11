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

variable "auto_scale_cool_down_period_out" {
  type = number
}

variable "auto_scale_cool_down_period_in" {
  type = number
}

variable "cpu_scale_in_threshold" {
  type = number
}

variable "cpu_scale_out_threshold" {
  type = number
}

variable "scaling_out_adjustment" {
  description = "Amount of ECS tasks we want to scale out at one time"
  type        = number
}

variable "scaling_in_adjustment" {
  description = "Amount of ECS tasks we want to scale in at one time"
  type        = number
}
