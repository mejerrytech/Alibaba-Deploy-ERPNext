variable "access_key" {
  description = "Alibaba Cloud Access Key"
  type        = string
}

variable "secret_key" {
  description = "Alibaba Cloud Secret Key"
  type        = string
}

variable "region" {
  description = "Alibaba Cloud region"
  type        = string
  default     = "me-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "ecs_instance_type" {
  description = "ECS instance type"
  type        = string
  default     = "ecs.t6-c1m2.large"
}

variable "ecs_password" {
  description = "Password for the ECS root user"
  type        = string
  sensitive   = true
}
