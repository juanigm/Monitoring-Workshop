terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-tfstates2"
    storage_account_name = "tfstatepractice"
    container_name       = "tfstatecontainer"
    key                  = "prod.terraform.tfstate"
  }
}