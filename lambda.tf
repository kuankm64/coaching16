# 1. Define the IAM Role for the Lambdas
resource "aws_iam_role" "lambda_role" {
  name = "multi_lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# 2. Attach basic execution policy (for CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 3. Use a Local Map to define your 2 Lambdas
locals {
  functions = {
    "lambda_one" = "create-url-lambda.py"
    "lambda_two" = "retrieve-url-lambda.py"
  }
}

# 4. Zip the code files (Terraform needs .zip files for Lambda)
data "archive_file" "lambda_zip" {
  for_each    = local.functions
  type        = "zip"
  source_file = "${path.module}/lambda_code/${each.value}"
  output_path = "${path.module}/lambda_code/${each.key}.zip"
}

# 5. Create the 2 Lambda Functions
resource "aws_lambda_function" "my_lambdas" {
  for_each      = local.functions
  function_name = each.key
  role          = aws_iam_role.lambda_role.arn
  handler       = "${each.key}.handler" # Assumes function name is the file name
  runtime       = "python3.9"

  filename         = data.archive_file.lambda_zip[each.key].output_path
  source_code_hash = data.archive_file.lambda_zip[each.key].output_base64sha256
}