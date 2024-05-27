variable "vm_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "pub_ip_name" {
  type = string
}

variable "user" {
  type = string
  default = "azureuser"
  description = "user for admin ssh key"
}
variable "admin_username" {
  type = string
  default = "adminuser"
  description = "Admin username for instance"
}

variable "size" {
  type = string
  default = "Standard_D2s_v3"
  description = "Instance size"
}

variable "subnet_id" {
  type = string
  description = "Subnet ID for NIC"
}
