# Create a Virtual Network within the Resource Group
resource azurerm_virtual_network main {
  name                = "${var.projectPrefix}-network"
  address_space       = [var.cidr]
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

# Create a Public IP for the Virtual Machines
resource azurerm_public_ip lbpip {
  name                         = "${var.projectPrefix}-lb-pip"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  allocation_method = "Dynamic"
  domain_name_label            = "${var.projectPrefix}lbpip"
}

# Create the Management Subnet within the Virtual Network
resource azurerm_subnet mgmt {
  name                 = "mgmt"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefix       = var.subnets["subnet1"]
}

# Create the external Subnet within the Virtual Network
resource azurerm_subnet external {
  name                 = "external"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefix       = var.subnets["subnet2"]
}

# Create the internal Subnet within the Virtual Network
resource azurerm_subnet internal {
  name                 = "internal"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefix       = var.subnets["subnet3"]
}

# Obtain Gateway IP for each Subnet
locals {
  depends_on = [azurerm_subnet.mgmt, azurerm_subnet.external]
  mgmt_gw    = "${cidrhost(azurerm_subnet.mgmt.address_prefix, 1)}"
  ext_gw     = "${cidrhost(azurerm_subnet.external.address_prefix, 1)}"
  int_gw     = "${cidrhost(azurerm_subnet.internal.address_prefix, 1)}"
}