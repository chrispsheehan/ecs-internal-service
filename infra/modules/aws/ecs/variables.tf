variable "project_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "container_port" {
  type = number
}

variable "task_definition_arn" {
  type = string
}

variable "local_tunnel" {
  type    = bool
  default = false
}

variable "xray_enabled" {
  type = bool
}

variable "wait_for_steady_state" {
  type    = bool
  default = true
}