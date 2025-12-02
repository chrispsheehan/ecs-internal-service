variable "vpc_id" {
  type = string
}

variable "service_name" {
  type = string
}

variable "container_port" {
  type = number
}

variable "load_balancer_arn" {
  type = string
}

variable "api_id" {
  type = string
}

variable "connection_id" {
  type = string
}

variable "default_target_group_arn" {
  type = string
}