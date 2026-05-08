resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "/aws/apigateway/url-shortener"
  retention_in_days = 14
}