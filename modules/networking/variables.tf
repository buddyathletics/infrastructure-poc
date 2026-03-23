variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_count" {
  description = "Number of public subnets"
  type        = number
  default     = 2
}

variable "enable_private_subnets" {
  description = "Whether to create private subnets (for databases, etc.)"
  type        = bool
  default     = false
}

variable "private_subnet_count" {
  description = "Number of private subnets (only used if enable_private_subnets is true)"
  type        = number
  default     = 2
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
