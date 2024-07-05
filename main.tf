resource "azurerm_resource_group" "aks_rg" {
  name     = "aks-rg"
  location = "eastus2"

  tags = {
    environment = "Test"
    Terraform   = true
  }
}

module "vnet" {
  source  = "Azure/vnet/azurerm"
  version = "4.1.0"
  
  vnet_name     = "aks-vnet"
  address_space = ["10.224.0.0/12"]
  
  resource_group_name = azurerm_resource_group.aks_rg.name
  vnet_location       = azurerm_resource_group.aks_rg.location
  use_for_each        = false

  subnet_names    = [var.cluster_subnet_name]
  subnet_prefixes = ["10.224.0.0/16"]

  nsg_ids = {
    (var.cluster_subnet_name) = azurerm_network_security_group.aks_nsg.id
  }
}

module "aks" {
  source = "./modules/aks"

  name       = "${random_pet.random_kubernetes_cluster_name.id}-k8s"
  dns_prefix = "${random_pet.random_kubernetes_dns_prefix.id}-k8s"

  kubernetes_version = "1.29.4"

  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  subnet_id           = lookup(module.vnet.vnet_subnets_name_id,var.cluster_subnet_name) 
}