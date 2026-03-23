output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}

output "ecs_cluster_arn" {
  value = module.networking.ecs_cluster_arn
}

output "ecs_cluster_name" {
  value = module.networking.ecs_cluster_name
}
