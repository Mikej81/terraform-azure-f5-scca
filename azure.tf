# Configure the Microsoft Azure Provider, replace Service Principal and Subscription with your own
provider "azurerm" {
    version = "~> 2.15.0"
    features{}
}

provider "http" {
}

# Create a Resource Group for the new Virtual Machines
resource azurerm_resource_group main {
  name     = "${var.projectPrefix}_rg"
  location = var.location
}