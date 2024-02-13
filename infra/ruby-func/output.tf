
output "function_url" {
  value = aws_lambda_function_url.main.function_url
}

output "function" {
  value = aws_lambda_function.main
}
