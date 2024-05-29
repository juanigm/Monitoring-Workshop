
variable "name" {
  type = string
}

variable "location" {
  type = string
  default = "eastus2"
}

variable "resource_group_name" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "kubernetes_version" {
  type = string
  default = "1.26.3"
}

variable "default_node_pool_node_count" {
  type = number
  default = 2  
}

variable "default_node_pool_name" {
  type = string
  default = "default"  
}

variable "default_node_pool_vm_size" {
  type = string
  default = "Standard_D2_v2"  
}

variable "default_node_pool_os_disk_size_gb" {
  type = number
  default = 30  
}