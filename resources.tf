resource "null_resource" "nsg-name" {

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "az network public-ip list -g ${module.aks.node-rg} --query '[].{name:name}'[0] | jq -r .name | tr -d '\n' > pip_name.txt"
  }

  provisioner "local-exec" {
    command = "az network nsg list -g ${module.aks.node-rg} --query '[].{name:name}'[0] | jq -r .name | tr -d '\n' > nsg_name.txt"
  }

}

data "local_file" "pip" {
  filename = "${path.root}/pip_name.txt"

  depends_on = [ null_resource.nsg-name ]
}

data "local_file" "nsg" {
  filename = "${path.root}/nsg_name.txt"

  depends_on = [ null_resource.nsg-name ]
}


data "azurerm_public_ip" "aks_pip_defult" {
    name                = data.local_file.pip.content
    resource_group_name = module.aks.node-rg

    depends_on = [ null_resource.nsg-name]
}

resource "azurerm_network_security_rule" "grafana_rule" {
  name                        = "grafana"
  priority                    = 501
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3000"
  source_address_prefix       = "*"
  destination_address_prefix  = data.azurerm_public_ip.aks_pip_defult.ip_address
  resource_group_name         = module.aks.node-rg
  network_security_group_name = data.local_file.nsg.content

  depends_on = [ data.azurerm_public_ip.aks_pip_defult ]
}

resource "azurerm_network_security_rule" "prometheus_rule" {
  name                        = "prometheus"
  priority                    = 502
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9090"
  source_address_prefix       = "*"
  destination_address_prefix  = data.azurerm_public_ip.aks_pip_defult.ip_address
  resource_group_name         = module.aks.node-rg
  network_security_group_name = data.local_file.nsg.content

  depends_on = [ data.azurerm_public_ip.aks_pip_defult ]
}

resource "azurerm_network_security_rule" "myapp_rule" {
  name                        = "myapp"
  priority                    = 503
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "*"
  destination_address_prefix  = data.azurerm_public_ip.aks_pip_defult.ip_address
  resource_group_name         = module.aks.node-rg
  network_security_group_name = data.local_file.nsg.content

  depends_on = [ data.azurerm_public_ip.aks_pip_defult ]
}

variable "yaml-files" {
  type = list(string)
  default = [ "grafana", "prometheus", "myapp" ]
}

resource "null_resource" "get-nsg-name" {

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "for yaml in $YAMLS; do sed -i 's;service.beta.kubernetes.io/azure-load-balancer-resource-group: .*;service.beta.kubernetes.io/azure-load-balancer-resource-group: ${module.aks.node-rg};g' manifest/$yaml/$yaml-service.yaml; done"
    environment = { YAMLS = join(" ", var.yaml-files) }
  }

  provisioner "local-exec" {
    command = "for yaml in $YAMLS; do sed -i 's;service.beta.kubernetes.io/azure-pip-name: .*;service.beta.kubernetes.io/azure-pip-name: ${data.local_file.pip.content};g' manifest/$yaml/$yaml-service.yaml; done"
    environment = { YAMLS = join(" ", var.yaml-files) }
  }
}
