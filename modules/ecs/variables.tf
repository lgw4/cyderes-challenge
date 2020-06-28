variable "namespace" {
  type = string
}

variable "nginx_image" {
  type = string
}

variable "sg" {
  type = any
}

variable "vpc" {
  type = any
}
