output "api_full_domain_name" {
  description = "The full FQDN of the API Gateway custom domain"
  value       = aws_apigatewayv2_domain_name.custom.domain_name
}

output "api_endpoint" {
  description = "The internal API Gateway endpoint"
  value       = aws_apigatewayv2_api.api.api_endpoint
}

output "route53_zone_id" {
  description = "The Route 53 Hosted Zone ID being used"
  value       = data.aws_route53_zone.main.zone_id
}