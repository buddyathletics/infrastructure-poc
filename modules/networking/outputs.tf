output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets (empty if not enabled)"
  value       = aws_subnet.private[*].id
}

output "ecs_cluster_arn" {
  description = "ARN of the shared ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_cluster_name" {
  description = "Name of the shared ECS cluster"
  value       = aws_ecs_cluster.main.name
}
