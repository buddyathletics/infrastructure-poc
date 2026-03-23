# --- Required ---

variable "app_name" {
  description = "Unique application name. Used in all resource names and ECR repo."
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
}

variable "vpc_id" {
  description = "VPC ID to deploy into"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for ECS tasks"
  type        = list(string)
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "ecs_cluster_arn" {
  description = "ARN of the ECS cluster to deploy into"
  type        = string
}

# --- Optional ---

variable "image_tag" {
  description = "Docker image tag to deploy (e.g., latest, git SHA, semver)"
  type        = string
  default     = "latest"
}

variable "cpu" {
  description = "Fargate CPU units"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate memory in MB"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of running tasks"
  type        = number
  default     = 1
}

variable "assign_public_ip" {
  description = "Whether tasks get public IPs"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

variable "ingress_cidr_blocks" {
  description = "CIDR blocks allowed inbound to the container port"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "environment_variables" {
  description = "Container environment variables"
  type        = list(object({ name = string, value = string }))
  default     = []
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
