output "node-rg" {
  value = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "location" {
  value = azurerm_kubernetes_cluster.aks.location
}