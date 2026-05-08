# Find existing hosted zone
data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

# Request the certificate for your subdomain
resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.project_name}.${var.domain_name}"
  validation_method = "DNS"

  tags = {
    Name = "${var.project_name}-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# DNS record of domain ownership
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
}

# Wait for AWS to verify the DNS record and issue the cert
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# API resource
resource "aws_apigatewayv2_api" "api" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"
}

# Custom domain name configuration in API Gateway
resource "aws_apigatewayv2_domain_name" "custom" {
  domain_name = "${var.project_name}.${var.domain_name}"

  domain_name_configuration {
    certificate_arn = aws_acm_certificate_validation.cert.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

# Map the custom domain to the API
resource "aws_apigatewayv2_api_mapping" "main" {
  api_id      = aws_apigatewayv2_api.api.id
  domain_name = aws_apigatewayv2_domain_name.custom.id
  stage       = "$default"
}

# Point subdomain to the API Gateway endpoint
resource "aws_route53_record" "api" {
  name    = aws_apigatewayv2_domain_name.custom.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.main.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.custom.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.custom.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}