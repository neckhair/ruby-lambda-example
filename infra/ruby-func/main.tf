data "aws_iam_policy_document" "assume-role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "main-func" {
  name               = var.function-name
  assume_role_policy = data.aws_iam_policy_document.assume-role.json
}

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
  role          = aws_iam_role.main-func.arn
  handler       = var.handler

  runtime = var.runtime

  s3_bucket        = var.bucket-name
  s3_key           = aws_s3_object.deploy-package.key
  source_code_hash = data.archive_file.deploy-package.output_base64sha256

  depends_on = [aws_s3_object.deploy-package]
}
