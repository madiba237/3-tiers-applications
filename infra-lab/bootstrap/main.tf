terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. Le Bucket S3 pour stocker les fichiers .tfstate
resource "aws_s3_bucket" "terraform_state" {
  # Le nom doit être globalement unique sur tout AWS
  bucket        = "${var.project_name}-tf-state-bucket"
  force_destroy = false # Évite la suppression accidentelle de tes états en prod

  lifecycle {
    prevent_destroy = true # Sécurité supplémentaire contre le "terraform destroy" accidentel
  }
}

# Activer le versionning (indispensable pour pouvoir restaurer un état corrompu)
resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Chiffrer le bucket S3 (les états contiennent des données sensibles comme des mots de passe)
resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloquer tout accès public au bucket S3 (Règle de sécurité stricte)
resource "aws_s3_bucket_public_access_block" "state_public_block" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 2. La Table DynamoDB pour la gestion des verrous (State Locking)
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.project_name}-tf-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID" # Cette clé est obligatoire pour le backend Terraform

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Outputs utiles à copier-coller dans ton projet principal
output "s3_bucket_name" {
  value = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_locks.id
}