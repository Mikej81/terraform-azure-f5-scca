terraform {
  required_version = "~> 0.13"
}

# Configure the Microsoft Azure Provider, replace Service Principal and Subscription with your own
provider "azurerm" {
  version = "~> 2.15.0"
  features {}
}

provider "http" {
}
