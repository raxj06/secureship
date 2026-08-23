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
resource "aws_iam_role" "eso" {
  name = "secureship-eso"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = module.eks.oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${module.eks.oidc_provider}:sub" = "system:serviceaccount:external-secrets:external-secrets"
          "${module.eks.oidc_provider}:aud" = "sts.amazonaws.com"
        }
      }
    }]
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
