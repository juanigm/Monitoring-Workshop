data "external" "public_ip_name" {
  program = ["bash", "${path.module}/public-ip-name.sh", "${module.aks.node-rg}"]
}

data "azurerm_public_ip" "aks_pip_defult" {
  name                = data.external.public_ip_name.result["name"]
  resource_group_name = module.aks.node-rg
}

resource "null_resource" "generate_kustomize" {

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
    cat > manifest/kustomization.yaml <<EOF
    resources:
      - prometheus/service.yaml
      - pushgateway/service.yaml
      - myapp/service.yaml
      - grafana/service.yaml
      - alertmanager/service.yaml

    commonAnnotations:
      service.beta.kubernetes.io/azure-load-balancer-resource-group: ${module.aks.node-rg}
      service.beta.kubernetes.io/azure-pip-name: ${data.external.public_ip_name.result["name"]}
    EOF
    EOT
  }
}

resource "azurerm_network_security_group" "aks_nsg" {
  name                = "aks-nsg"
  location            = module.aks.location
  resource_group_name = module.aks.node-rg  

  tags = {
    environment = "Workshop"
  }
}

resource "azurerm_network_security_rule" "deployment_rules" {

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
  source_address_prefix       = "*"
  destination_port_range      = each.value.port
  destination_address_prefix  = data.azurerm_public_ip.aks_pip_defult.ip_address
  resource_group_name         = module.aks.node-rg
  network_security_group_name = azurerm_network_security_group.aks_nsg.name

  depends_on = [data.azurerm_public_ip.aks_pip_defult]
}

resource "null_resource" "checkov" {
  provisioner "local-exec" {
    command = "checkov -o cli -o github_failed_only --output-file-path checkov --framework terraform --download-external-modules true --quiet --compact -s -d ."
  }

  triggers = {
    always_run = timestamp()
  }
}