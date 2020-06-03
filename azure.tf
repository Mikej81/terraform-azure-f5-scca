# Configure the Microsoft Azure Provider, replace Service Principal and Subscription with your own
provider azurerm {
  version = "=1.44.0"
}

# Create a Resource Group for the new Virtual Machines
resource azurerm_resource_group main {
  name     = "${var.projectPrefix}_rg"
  location = var.location
}