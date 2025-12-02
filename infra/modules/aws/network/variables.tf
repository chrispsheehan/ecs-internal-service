variable "vpc_name" {
  type = string
}

variable "project_name" {
  type = string
}

variable "aws_region" {
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

variable "state_bucket" {
  type = string
}

variable "environment" {
  type = string
}
