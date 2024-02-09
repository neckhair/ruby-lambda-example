
resource "aws_iam_role" "hello-world-func" {
  name               = "HelloWorldFunc"
  assume_role_policy = data.aws_iam_policy_document.assume-role.json

  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
}

module "hello-world" {
  source = "./ruby-func"

  function-name = "hello-world"
  bucket-name   = aws_s3_bucket.source-code.bucket
  dist-path     = "../dist"
  source-dir    = "../build/hello-world"
  handler       = "hello-world.handler"
  iam_role_arn  = aws_iam_role.hello-world-func.arn
}
