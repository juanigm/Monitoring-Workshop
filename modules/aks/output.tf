output "node-rg" {
  value = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "pip_name" {
  value = trimspace(file("${path.root}/pip_name.txt"))
}
output "nsg_name" {
  value = trimspace(file("${path.root}/nsg_name.txt"))
}