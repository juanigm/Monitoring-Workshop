terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.11.0, <4.0"
    }

    external = {
      source = "hashicorp/external"
      version = "2.3.3"
    }
  }
}

provider "azurerm" {
  features {
    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = false
    }
  }
  # skip_provider_registration = true
  # azurerm_resource_provider_registration => resource for registrating preview features
}