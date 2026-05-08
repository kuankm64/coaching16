terraform {
  backend "s3" {
    bucket = "sctp-ce12-tfstate-bucket"
    key    = "coaching16-url-shortener/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

provider "aws" {
  region = var.aws_region
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
