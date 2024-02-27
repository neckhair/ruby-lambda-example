
data "archive_file" "deploy-package" {
  output_path = "${var.dist-path}/${var.function-name}-package.zip"
  type        = "zip"
  source_dir  = var.source-dir
}

data "archive_file" "gem-layer" {
  output_path = "${var.dist-path}/${var.function-name}-gems.zip"
  type        = "zip"
  source_dir  = "${var.source-dir}-gems"
}

resource "aws_s3_object" "deploy-package" {
  bucket = var.bucket-name
  key    = "${var.function-name}-source.zip"
  source = data.archive_file.deploy-package.output_path
  etag   = data.archive_file.deploy-package.output_md5
}

resource "aws_s3_object" "gems-layer" {
  bucket = var.bucket-name
  key    = "${var.function-name}-gems.zip"
  source = data.archive_file.gem-layer.output_path
  etag   = data.archive_file.gem-layer.output_md5
}

resource "aws_lambda_layer_version" "gems-layer" {
  s3_bucket  = var.bucket-name
  s3_key     = aws_s3_object.gems-layer.key
  layer_name = "${var.function-name}-gems"

  compatible_runtimes = [var.runtime]

  source_code_hash = data.archive_file.gem-layer.output_base64sha256
}

resource "aws_lambda_function" "main" {
  function_name = var.function-name
  role          = var.iam_role_arn
  handler       = var.handler

  runtime = var.runtime
  timeout = var.func_timeout

  s3_bucket        = var.bucket-name
  s3_key           = aws_s3_object.deploy-package.key
  source_code_hash = data.archive_file.deploy-package.output_base64sha256

  depends_on = [aws_s3_object.deploy-package]

  layers = [aws_lambda_layer_version.gems-layer.arn]

  environment {
    variables = {
      RAILS_ENV = var.rails_env
    }
  }
}

resource "aws_lambda_function_url" "main" {
  function_name      = aws_lambda_function.main.function_name
  authorization_type = "NONE"
}
