variable "function-name" {
  type = string
}

variable "bucket-name" {
  type = string
}

variable "dist-path" {
  type = string
}

variable "source-dir" {
  type = string

}

variable "handler" {
  type = string
}

variable "runtime" {
  type    = string
  default = "ruby3.2"
}
