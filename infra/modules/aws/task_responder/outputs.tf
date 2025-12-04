output "task_definition_arn" {
  value = module.task_responder.task_definition_arn
}

output "cloudwatch_log_group" {
  value = module.task_responder.cloudwatch_log_group
}

output "root_path" {
  value = module.task_responder.root_path
}

output "service_name" {
  value = module.task_responder.service_name
}
