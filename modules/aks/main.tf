resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name            = var.default_node_pool_name
    node_count      = var.default_node_pool_node_count
    vm_size         = var.default_node_pool_vm_size
    os_disk_size_gb = var.default_node_pool_os_disk_size_gb
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "Demo"
  }
}

resource "local_file" "kubeconfig" {
  depends_on   = [azurerm_kubernetes_cluster.aks]
  filename     = "kubeconfig"
  content      = azurerm_kubernetes_cluster.aks.kube_config_raw
}


resource "null_resource" "get-nsg-name" {

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "az network public-ip list -g ${azurerm_kubernetes_cluster.aks.node_resource_group} --query '[].{name:name}'[0] | jq -r .name | tr -d '\n' > pip_name.txt"
  }

  provisioner "local-exec" {
    command = "az network nsg list -g ${azurerm_kubernetes_cluster.aks.node_resource_group} --query '[].{name:name}'[0] | jq -r .name | tr -d '\n' > nsg_name.txt"
  }

  depends_on = [ azurerm_kubernetes_cluster.aks ]
}

