variable "project_name" {
  description = "Prefix for all resources"
  type        = string
  default     = "coaching16-url-shortener"
}

variable "domain_name" {
  description = "Shared SCTP domain"
  type        = string
  default     = "sctp-sandbox.com"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-southeast-1"
}