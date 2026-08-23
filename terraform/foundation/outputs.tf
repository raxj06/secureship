output "ecr_urls" {
  description = "ECR repository URLs by service"
  value       = { for k, v in aws_ecr_repository.services : k => v.repository_url }
}

output "ecr_arns" {
  description = "ECR repository ARNs by service"
  value       = { for k, v in aws_ecr_repository.services : k => v.arn }
}

output "ci_role_arn" {
  description = "ARN of the secureship-ci IAM role (use as AWS_ROLE_ARN in GitHub Actions)"
  value       = aws_iam_role.ci.arn
}

output "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}
