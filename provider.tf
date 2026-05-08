terraform {
  backend "s3" {
    bucket = "sctp-ce12-tfstate-bucket"
    # Use your name_prefix here to keep your state file isolated
    key    = "coaching16-url-shortener/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

provider "aws" {
  region = "ap-southeast-1"

  default_tags {
    tags = {
      Project   = var.name_prefix
      ManagedBy = "Terraform"
    }
  }
}

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}