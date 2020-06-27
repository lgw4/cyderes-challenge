variable "namespace" {
  type = string
}

variable "sg" {
  type = any
}

variable "vpc" {
  type = any
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
  type        = string
}

variable "private_subnet" {
  type = string
}

variable "public_subnet" {
  type = string
}
