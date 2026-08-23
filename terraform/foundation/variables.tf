variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "account_id" {
  description = "AWS account ID for cloudsentry"
  type        = string
  default     = "081382613682"
}

variable "github_org" {
  description = "GitHub org/user for OIDC trust"
  type        = string
  default     = "raxj06"
}

variable "github_repo" {
  description = "GitHub repo name for OIDC trust"
  type        = string
  default     = "secureship"
}

variable "services" {
  description = "Service names — one ECR repo per service"
  type        = list(string)
  default     = ["api-gateway", "order-service", "tracking-service", "notification-service"]
}
