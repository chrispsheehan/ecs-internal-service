variable "service_name" {
  type = string
}

variable "load_balancer_listener_arn" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}
