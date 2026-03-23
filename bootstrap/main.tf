terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # NOTE: No dynamodb_table here initially (chicken-and-egg: this creates the table).
  # After first apply, run `terraform init -migrate-state` with dynamodb_table added.
  backend "s3" {
    bucket = "buddy-athletics-terraform-state-bucket"
    key    = "bootstrap/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "buddy-athletics"
}

# DynamoDB table for Terraform state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "buddy-athletics-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name    = "terraform-state-locks"
    Project = "buddy-athletics"
  }
}

# GitHub OIDC Provider for Actions
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # AWS no longer validates thumbprints for GitHub OIDC (since July 2023). Dummy value per AWS guidance.
  thumbprint_list = ["ffffffffffffffffffffffffffffffffffffffff"]

  tags = {
    Name    = "github-actions-oidc"
    Project = "buddy-athletics"
  }
}

# IAM Role for GitHub Actions deployments
resource "aws_iam_role" "github_actions_deploy" {
  name = "buddy-athletics-github-actions-deploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike = {
          # Scoped to specific branches. Add new repos here as onboarded.
          "token.actions.githubusercontent.com:sub" = [
            "repo:buddyathletics/buddyapp-poc:ref:refs/heads/main",
            "repo:buddyathletics/buddyapp-poc:ref:refs/heads/dev",
            "repo:buddyathletics/infrastructure-poc:ref:refs/heads/main"
          ]
        }
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = {
    Name    = "github-actions-deploy-role"
    Project = "buddy-athletics"
  }
}

# Policy: Scoped permissions for deploy role
resource "aws_iam_role_policy" "github_actions_deploy_policy" {
  name = "deploy-policy"
  role = aws_iam_role.github_actions_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ECSFullAccess"
        Effect   = "Allow"
        Action   = ["ecs:*"]
        Resource = "*"
      },
      {
        Sid    = "EC2NetworkingForECS"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = ["logs:*"]
        Resource = [
          "arn:aws:logs:us-east-1:643025068953:log-group:/ecs/*",
          "arn:aws:logs:us-east-1:643025068953:log-group:/ecs/*:*",
          "arn:aws:logs:us-east-1:643025068953:log-group::log-stream:"
        ]
      },
      {
        Sid    = "IAMRoleManagement"
        Effect = "Allow"
        Action = [
          "iam:PassRole",
          "iam:GetRole",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfilesForRole"
        ]
        Resource = "arn:aws:iam::*:role/*-ecs-task-execution-role"
      },
      {
        Sid    = "ECRAccess"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:DescribeImages",
          "ecr:CreateRepository",
          "ecr:DeleteRepository",
          "ecr:ListTagsForResource",
          "ecr:TagResource"
        ]
        Resource = "*"
      },
      {
        Sid    = "TerraformStateS3"
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket", "s3:DeleteObject"]
        Resource = [
          "arn:aws:s3:::buddy-athletics-terraform-state-bucket",
          "arn:aws:s3:::buddy-athletics-terraform-state-bucket/*"
        ]
      },
      {
        Sid      = "TerraformStateLocking"
        Effect   = "Allow"
        Action   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
        Resource = [aws_dynamodb_table.terraform_locks.arn]
      }
    ]
  })
}

# Secrets Manager secret for GHCR credentials (ECS pulls from GHCR at runtime)
# After apply: manually set the secret value via AWS CLI:
#   aws secretsmanager put-secret-value --secret-id ghcr-credentials \
#     --secret-string '{"username":"<github-machine-user>","password":"<PAT-with-read:packages>"}'
resource "aws_secretsmanager_secret" "ghcr_credentials" {
  name        = "ghcr-credentials"
  description = "GitHub Container Registry credentials for ECS to pull images"

  tags = {
    Name    = "ghcr-credentials"
    Project = "buddy-athletics"
  }
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_locks.name
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions_deploy.arn
}

output "ghcr_secret_arn" {
  value = aws_secretsmanager_secret.ghcr_credentials.arn
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github.arn
}
