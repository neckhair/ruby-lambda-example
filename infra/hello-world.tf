data "aws_iam_policy_document" "hello-world-assume-role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "hello-world-func" {
  name               = "hello-world-func"
  assume_role_policy = data.aws_iam_policy_document.hello-world-assume-role.json
}

data "archive_file" "hello-world-package" {
  output_path = "../package.zip"
  type        = "zip"
  source_dir  = "../build"
}

resource "aws_s3_object" "hello-world-package" {
  bucket = aws_s3_bucket.source-code.id
  key    = var.package-s3-key
  source = data.archive_file.hello-world-package.output_path
  etag   = data.archive_file.hello-world-package.output_md5
}

resource "aws_lambda_function" "hello-world" {
  function_name = "hello-world"
  role          = aws_iam_role.hello-world-func.arn
  handler       = "hello-world.handler"

  runtime = "ruby3.2"

  s3_bucket        = aws_s3_bucket.source-code.id
  s3_key           = var.package-s3-key
  source_code_hash = data.archive_file.hello-world-package.output_base64sha256

  depends_on = [aws_s3_object.hello-world-package]
}
