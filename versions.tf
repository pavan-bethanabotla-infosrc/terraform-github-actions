terraform {
  required_version = "~> 1.11.4" # Or your desired Terraform CLI version

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0" # Or your desired AzureRM provider version
    }
    # Add other required providers here
  }

  
# You can also define provider configurations here, e.g.:
# provider "azurerm" {
#   features {}
# }