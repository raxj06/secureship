# Secrets Manager - dummy values for dev
resource "aws_secretsmanager_secret" "database" {
  name                    = "secureship/dev/database"
  recovery_window_in_days = 0
  tags                    = { Project = "secureship" }
}

resource "aws_secretsmanager_secret_version" "database" {
  secret_id     = aws_secretsmanager_secret.database.id
  secret_string = jsonencode({ DATABASE_URL = "postgresql://secureship:changeme@db:5432/secureship" })
}

resource "aws_secretsmanager_secret" "jwt" {
  name                    = "secureship/dev/jwt"
  recovery_window_in_days = 0
  tags                    = { Project = "secureship" }
}

resource "aws_secretsmanager_secret_version" "jwt" {
  secret_id     = aws_secretsmanager_secret.jwt.id
  secret_string = jsonencode({ JWT_SECRET = "dev-placeholder-secret-change-me-32chars" })
}

# ESO IRSA role - allow external-secrets SA to read secureship/* secrets
# ponytail: dual OIDC provider trust for EKS issuer migration (old vs new domain)
locals {
  oidc_id = split("/", module.eks.oidc_provider)[2]
}
resource "aws_iam_role" "eso" {
  name = "secureship-eso"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Federated = module.eks.oidc_provider_arn }
        Action    = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(module.eks.oidc_provider_arn, "arn:aws:iam::${var.account_id}:oidc-provider/", "")}:sub" = "system:serviceaccount:external-secrets:external-secrets"
            "${replace(module.eks.oidc_provider_arn, "arn:aws:iam::${var.account_id}:oidc-provider/", "")}:aud" = "sts.amazonaws.com"
          }
        }
      },
      {
        Effect    = "Allow"
        Principal = { Federated = "arn:aws:iam::${var.account_id}:oidc-provider/oidc.eks.${var.region}.amazonaws.com/id/${local.oidc_id}" }
        Action    = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "oidc.eks.${var.region}.amazonaws.com/id/${local.oidc_id}:sub" = "system:serviceaccount:external-secrets:external-secrets"
            "oidc.eks.${var.region}.amazonaws.com/id/${local.oidc_id}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
  tags = { Project = "secureship" }
}

resource "aws_iam_role_policy" "eso_read" {
  name = "eso-read"
  role = aws_iam_role.eso.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
      Resource = "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:secureship/*"
    }]
  })
}
