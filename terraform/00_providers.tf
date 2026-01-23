variable "ARM_SUBSCRIPTION_ID" { type = string }
variable "ARM_TENANT_ID" { type = string }
variable "ARM_CLIENT_ID" { type = string }
variable "ARM_CLIENT_SECRET" { type = string }
terraform {
  required_version = ">=1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.58.0"
    }
  }
}
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = var.ARM_SUBSCRIPTION_ID
  tenant_id       = var.ARM_TENANT_ID
  client_id       = var.ARM_CLIENT_ID
  client_secret   = var.ARM_CLIENT_SECRET
}
