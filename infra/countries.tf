resource "aws_dynamodb_table" "country" {
  name           = "Country"
  billing_mode   = "PROVISIONED"
  read_capacity  = 3
  write_capacity = 3
  hash_key       = "id"

  point_in_time_recovery {
    enabled = false
  }

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_iam_role" "countries-func" {
  name               = "CountriesFunc"
  assume_role_policy = data.aws_iam_policy_document.assume-role.json

  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]

  inline_policy {
    name = "dynamodb-access"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "dynamodb:BatchGetItem",
            "dynamodb:Describe*",
            "dynamodb:List*",
            "dynamodb:GetItem",
            "dynamodb:Query",
            "dynamodb:Scan",
            "dynamodb:PartiQLSelect",
            "dynamodb:WriteItem",
            "dynamodb:PutItem",
            "dynamodb:Batch*",
            "dynamodb:Transact*",
          ]
          Effect   = "Allow"
          Resource = aws_dynamodb_table.country.arn
        },
      ]
    })
  }
}

module "countries" {
  source = "./ruby-func"

  function-name = "countries"
  bucket-name   = aws_s3_bucket.source-code.bucket
  dist-path     = "../dist"
  source-dir    = "../build/countries"
  handler       = "app.handler"
  iam_role_arn  = aws_iam_role.countries-func.arn
  func_timeout  = 15
}
