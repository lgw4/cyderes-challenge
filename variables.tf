variable "namespace" {
  description = "Project namespace"
  type        = string
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
  type        = string
}

variable "private_subnet" {
  description = "Private subnet"
  type        = string
}

variable "public_subnet" {
  description = "Public subnet"
  type        = string
}
