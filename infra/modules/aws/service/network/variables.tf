variable "vpc_id" {
  type = string
}

variable "service_name" {
  type = string
}

variable "service_path" {
  type = string
}

variable "container_port" {
  type = number
}

variable "load_balancer_arn" {
  type = string
}

variable "default_target_group_arn" {
  type = string
}

variable "default_http_listener_arn" {
  type = string
}