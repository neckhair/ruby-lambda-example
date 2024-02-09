variable "function-name" {
  type        = string
  description = "Name of the Lambda function."
}

variable "bucket-name" {
  type        = string
  description = "The name of the bucket where the built package should be stored."
}

variable "dist-path" {
  type        = string
  description = "The zip file with the source code and dependencies will be stored here."
}

variable "source-dir" {
  type        = string
  description = "The directory which contains the source code to package."
}

variable "handler" {
  type        = string
  description = "The name of the Ruby function to call."
}

variable "runtime" {
  type    = string
  default = "ruby3.2"
}

variable "iam_role_arn" {
  type = string
}

variable "func_timeout" {
  type    = number
  default = 3
}
