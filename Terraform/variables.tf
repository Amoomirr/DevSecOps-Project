variable "ami_value" {
  description = "This is the value of ami"
  default = "ami-019715e0d74f695be"
}

variable "instance_type_value" {
  description = "This is the value of instance_type"
  default = "c7i-flex.large"
}


variable "aws_access_key" {
 type = string
}

variable "aws_secret_key" {
type = string
}