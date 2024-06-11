resource "null_resource" "nsg-name" {

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "az network public-ip list -g ${module.aks.node-rg} --query '[].{name:name}'[0] | jq -r .name | tr -d '\n' > pip_name.txt"
  }

  # provisioner "local-exec" {
  #   command = "az network nsg list -g ${module.aks.node-rg} --query '[].{name:name}'[0] | jq -r .name | tr -d '\n' > nsg_name.txt"
  # }

}

data "local_file" "pip" {
  filename = "${path.root}/pip_name.txt"

  depends_on = [ null_resource.nsg-name ]
}

# data "local_file" "nsg" {
#   filename = "${path.root}/nsg_name.txt"

#   depends_on = [ null_resource.nsg-name ]
# }


data "azurerm_public_ip" "aks_pip_defult" {
    name                = data.local_file.pip.content
    resource_group_name = module.aks.node-rg

    depends_on = [ null_resource.nsg-name]
}

resource "azurerm_network_security_group" "aks_nsg" {
  name                = "aks-nsg"
  location            = module.aks.location
  resource_group_name = module.aks.node-rg  

  tags = {
    environment = "Workshop"
  }
}

resource "azurerm_network_security_rule" "grafana_rule" {

  for_each = {
    for index, service in var.services:
    service.name => service
  }

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value.port
  source_address_prefix       = "*"
  destination_address_prefix  = data.azurerm_public_ip.aks_pip_defult.ip_address
  resource_group_name         = module.aks.node-rg
  network_security_group_name = azurerm_network_security_group.aks_nsg.name

  depends_on = [ data.azurerm_public_ip.aks_pip_defult ]
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = tolist(module.vnet.subnet)[0].id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}


resource "null_resource" "get-nsg-name" {

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "for yaml in $YAMLS; do sed -i 's;service.beta.kubernetes.io/azure-load-balancer-resource-group: .*;service.beta.kubernetes.io/azure-load-balancer-resource-group: ${module.aks.node-rg};g' manifest/$yaml/service.yaml; done"
    environment = { YAMLS = join(" ", var.yaml-files) }
  }

  provisioner "local-exec" {
    command = "for yaml in $YAMLS; do sed -i 's;service.beta.kubernetes.io/azure-pip-name: .*;service.beta.kubernetes.io/azure-pip-name: ${data.local_file.pip.content};g' manifest/$yaml/service.yaml; done"
    environment = { YAMLS = join(" ", var.yaml-files) }
  }
}
