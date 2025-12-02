variable "cluster_id" {
  type = string
}

variable "service_name" {
  type = string
}

variable "container_port" {
  type    = number
  default = 3000
}

variable "task_definition_arn" {
  type = string
}

variable "connection_type" {
  description = "Type of connectivity/integration to use for the service (choices: internal, internal_dns, vpc_link)."
  type        = string
  default     = "internal"
  validation {
    condition     = can(regex("^(internal|internal_dns|vpc_link)$", var.connection_type))
    error_message = "connection_type must be one of: internal, internal_dns, vpc_link."
  }
}

variable "local_tunnel" {
  type    = bool
  default = false
}

variable "xray_enabled" {
  type    = bool
  default = false
}

variable "wait_for_steady_state" {
  type    = bool
  default = false
}