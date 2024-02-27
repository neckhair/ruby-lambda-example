
resource "aws_iam_role" "rails-func" {
  name               = "RailsFunc"
  assume_role_policy = data.aws_iam_policy_document.assume-role.json

  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
}

module "rails" {
  source = "./ruby-func"

  function-name = "rails"
  bucket-name   = aws_s3_bucket.source-code.bucket
  dist-path     = "../dist"
  source-dir    = "../build/on-rails"
  handler       = "lambda.handler"
  iam_role_arn  = aws_iam_role.rails-func.arn
}

resource "aws_api_gateway_rest_api" "rails" {
  name        = "RailsExample"
  description = "API GW for Rails Example"
}

resource "aws_api_gateway_resource" "rails-proxy" {
  rest_api_id = aws_api_gateway_rest_api.rails.id
  parent_id   = aws_api_gateway_rest_api.rails.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "rails-proxy" {
  rest_api_id   = aws_api_gateway_rest_api.rails.id
  resource_id   = aws_api_gateway_resource.rails-proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda-rails" {
  rest_api_id = aws_api_gateway_rest_api.rails.id
  resource_id = aws_api_gateway_method.rails-proxy.resource_id
  http_method = aws_api_gateway_method.rails-proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.rails.function.invoke_arn
}

resource "aws_api_gateway_method" "rails-proxy-root" {
  rest_api_id   = aws_api_gateway_rest_api.rails.id
  resource_id   = aws_api_gateway_rest_api.rails.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "rails-lambda-root" {
  rest_api_id = aws_api_gateway_rest_api.rails.id
  resource_id = aws_api_gateway_method.rails-proxy-root.resource_id
  http_method = aws_api_gateway_method.rails-proxy-root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.rails.function.invoke_arn
}

resource "aws_api_gateway_deployment" "rails" {
  depends_on = [
    aws_api_gateway_integration.lambda-rails,
    aws_api_gateway_integration.rails-lambda-root,
  ]

  rest_api_id = aws_api_gateway_rest_api.rails.id
  stage_name  = "test"
}

resource "aws_lambda_permission" "apigw-rails" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.rails.function.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.rails.execution_arn}/*/*"
}

output "Rails-URL" {
  value       = aws_api_gateway_deployment.rails.invoke_url
  description = "Rails URL"
}
