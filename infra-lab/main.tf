# ==============================================================================
# ALAIN'S VOTING APP - MAIN CONFIGURATION
# ==============================================================================
# Ce fichier sert de point d'entrée pour la configuration globale de Terraform.
# L'infrastructure est découpée de manière modulaire :
#   - network.tf : Configuration du VPC, des sous-réseaux et de la sécurité.
#   - compute.tf : Déploiement des instances EC2 et de la configuration SSH.
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Stockage de l'état sur le S3 sécurisé créé par le module de Bootstrap
  backend "s3" {
    bucket         = "alain-voting-app-tf-state-bucket"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "alain-voting-app-tf-state-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}