output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.app.name
}

output "security_group_id" {
  description = "Security group ID for the ECS tasks"
  value       = aws_security_group.ecs_tasks.id
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.app.name
}

output "task_definition_arn" {
  description = "ARN of the latest task definition"
  value       = aws_ecs_task_definition.app.arn
}
