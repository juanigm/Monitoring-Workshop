module "rg" {
  source = "./modules/ResourceGroups"

  name = "ansible-rg"
}

module "aks" {
  source = "./modules/AKS"

  name = "${random_pet.random_kubernetes_cluster_name.id}-k8s"
  location = module.rg.location
  resource_group_name = module.rg.name
  kubernetes_version = "1.29.4"
  dns_prefix = "${random_pet.random_kubernetes_dns_prefix.id}-k8s"

}