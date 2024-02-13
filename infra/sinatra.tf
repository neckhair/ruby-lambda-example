
resource "aws_iam_role" "sinatra-func" {
  name               = "SinatraFunc"
  assume_role_policy = data.aws_iam_policy_document.assume-role.json

  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
}

module "sinatra" {
  source = "./ruby-func"

  function-name = "sinatra"
  bucket-name   = aws_s3_bucket.source-code.bucket
  dist-path     = "../dist"
  source-dir    = "../build/sinatra"
  handler       = "lambda.handler"
  iam_role_arn  = aws_iam_role.sinatra-func.arn
}

resource "aws_api_gateway_rest_api" "sinatra" {
  name        = "SinatraExample"
  description = "API GW for Sinatra Example"
}

resource "aws_api_gateway_resource" "sinatra-proxy" {
  rest_api_id = aws_api_gateway_rest_api.sinatra.id
  parent_id   = aws_api_gateway_rest_api.sinatra.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "sinatra-proxy" {
  rest_api_id   = aws_api_gateway_rest_api.sinatra.id
  resource_id   = aws_api_gateway_resource.sinatra-proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda-sinatra" {
  rest_api_id = aws_api_gateway_rest_api.sinatra.id
  resource_id = aws_api_gateway_method.sinatra-proxy.resource_id
  http_method = aws_api_gateway_method.sinatra-proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.sinatra.function.invoke_arn
}

resource "aws_api_gateway_method" "sinatra-proxy-root" {
  rest_api_id   = aws_api_gateway_rest_api.sinatra.id
  resource_id   = aws_api_gateway_rest_api.sinatra.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "sinatra-lambda-root" {
  rest_api_id = aws_api_gateway_rest_api.sinatra.id
  resource_id = aws_api_gateway_method.sinatra-proxy-root.resource_id
  http_method = aws_api_gateway_method.sinatra-proxy-root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.sinatra.function.invoke_arn
}

resource "aws_api_gateway_deployment" "sinatra" {
  depends_on = [
    aws_api_gateway_integration.lambda-sinatra,
    aws_api_gateway_integration.sinatra-lambda-root,
  ]

  rest_api_id = aws_api_gateway_rest_api.sinatra.id
  stage_name  = "test"
}

resource "aws_lambda_permission" "apigw-sinatra" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.sinatra.function.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.sinatra.execution_arn}/*/*"
}

output "Sinatra-URL" {
  value       = aws_api_gateway_deployment.sinatra.invoke_url
  description = "Sinatra URL"
}
