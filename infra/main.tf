data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "hello_world_func" {
  name               = "hello-world-func"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "package" {
  output_path = "../build/package.zip"
  type        = "zip"
  source_dir  = "../build"
}

resource "aws_lambda_function" "hello_world" {
  filename      = data.archive_file.package.output_path
  function_name = "hello-world"
  role          = aws_iam_role.hello_world_func.arn
  handler       = "hello-world.handler"

  source_code_hash = data.archive_file.package.output_base64sha256

  runtime = "ruby3.2"
}
