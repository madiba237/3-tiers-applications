terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.54.0"
    }
  }
  backend "s3" {
    bucket         = "alain-backend-projet1-ironhack" 
    key            = "projet-ec2/terraform.tfstate" 
    region         = "us-east-1"                     
    encrypt        = true                            
  }
}
provider "aws" {
  
  region = "us-east-1"
}


 