output "task_arn" {
  value = module.task_caller.task_definition_arn
}

output "cloudwatch_log_group" {
  value = module.task_caller.cloudwatch_log_group
}

output "root_path" {
  value = module.task_caller.root_path
}

output "service_name" {
  value = module.task_caller.service_name
}
