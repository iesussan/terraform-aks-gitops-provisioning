# Configure desired versions of terraform, azurerm provider
terraform {
  required_providers {
    azurerm = {
      version = "~>3.97.1"
      source  = "hashicorp/azurerm"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~>1.2.24"
    }
    azapi = {
      source = "Azure/azapi"
      version = ">=1.13.1"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "2.50.0"
    }
  }
}

# Enable features for azurerm
provider "azurerm" {
  skip_provider_registration = "true"
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Access client_id, tenant_id, subscription_id and object_id configuration values
data "azurerm_client_config" "current" {}
