
resource "aws_s3_bucket" "source-code" {
  bucket_prefix = "source-code"
}

module "hello-world" {
  source = "./ruby-func"

  function-name = "hello-world"
  bucket-name   = aws_s3_bucket.source-code.bucket
  dist-path     = "../dist"
  source-dir    = "../build/hello-world"
  handler       = "hello-world.handler"
}

module "countries" {
  source = "./ruby-func"

  function-name = "countries"
  bucket-name   = aws_s3_bucket.source-code.bucket
  dist-path     = "../dist"
  source-dir    = "../build/countries"
  handler       = "app.handler"
}
