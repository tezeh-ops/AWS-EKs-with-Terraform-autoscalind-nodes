variable "private_cidr" {
  type    = list(string)
  default = ["10.0.0.0/19", "10.0.32.0/19"]
}
variable "availability_zones" {
  type    = list(string)
  default = ["us-east-2a", "us-east-2b"]
}

variable "public_cidr" {
  type    = list(string)
  default = ["10.0.64.0/19", "10.0.96.0/19"]
}