variable "vnet-name" {
  type    = string
  default = "ansible-vnet"
}

variable "location" {
  type    = string
  default = "eastus2"
}

variable "rg-name" {
  type = string
}

variable "sg-name" {
  type = string
}

variable "CIDR" {
  type = list(string)
}

variable "subnets" {
  type = map(any)

  default = {}
}