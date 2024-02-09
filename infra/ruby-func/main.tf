
data "archive_file" "deploy-package" {
  output_path = "${var.dist-path}/${var.function-name}-package.zip"
  type        = "zip"
  source_dir  = var.source-dir
}

resource "aws_s3_object" "deploy-package" {
  bucket = var.bucket-name
  key    = "${var.function-name}-source.zip"
  source = data.archive_file.deploy-package.output_path
  etag   = data.archive_file.deploy-package.output_md5
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
}
