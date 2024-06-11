module "rg" {
  source = "./modules/ResourceGroups"

  name = "ansible-rg"
}

module "vnet" {
  source = "./modules/networking"

  vnet-name = "aks-vent"

  rg-name = module.rg.name

  # sg-name = "aks-vnet-sg"

  CIDR = ["10.224.0.0/12"]

  subnets = {
    subnet1 = {
      name           = "aks-subnet"
      address_prefix = "10.224.0.0/16"
    }
  }

}

module "aks" {
  source = "./modules/AKS"

  name = "${random_pet.random_kubernetes_cluster_name.id}-k8s"
  location = module.rg.location
  resource_group_name = module.rg.name
  kubernetes_version = "1.29.4"
  dns_prefix = "${random_pet.random_kubernetes_dns_prefix.id}-k8s"
  subnet_id = tolist(module.vnet.subnet)[0].id
}