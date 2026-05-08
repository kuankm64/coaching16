variable "name_prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = "coaching16-url-shortener"
}

variable "domain_name" {
  description = "Shared SCTP domain"
  type        = string
  default     = "sctp-sandbox.com"
}