# Create a Virtual Network within the Resource Group
resource azurerm_virtual_network main {
  name                = "${var.projectPrefix}-network"
  address_space       = [var.cidr]
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

# Create a Public IP for the Virtual Machines
resource azurerm_public_ip lbpip {
  name                = "${var.projectPrefix}-lb-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.projectPrefix}lbpip"
}

# Create the Management Subnet within the Virtual Network
resource azurerm_subnet mgmt {
  name                 = "mgmt"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = [var.subnets["management"]]
}

# Create the external Subnet within the Virtual Network
resource azurerm_subnet external {
  name                 = "external"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = [var.subnets["external"]]
}

# Create the internal Subnet within the Virtual Network
resource azurerm_subnet internal {
  name                 = "internal"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = [var.subnets["internal"]]
}

# Create the external IPS subnet within the Vnet
resource azurerm_subnet inspect_external {
  count           = var.deploymentType == "three_tier" ? 1 : 0
  name                 = "inspect_external"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = [var.subnets["inspect_ext"]]

}
# Create the internal IPS subnet within the Vnet
resource azurerm_subnet inspect_internal {
  count           = var.deploymentType == "three_tier" ? 1 : 0
  name                 = "inspect_internal"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = [var.subnets["inspect_int"]]

}

# Create the VDMS Subnet within the Virtual Network
resource azurerm_subnet vdms {
  name = "vdms"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name = azurerm_resource_group.main.name
  address_prefixes = [var.subnets["vdms"]]
 }

# Obtain Gateway IP for each Subnet
locals {
  depends_on = [azurerm_subnet.mgmt, azurerm_subnet.external]
  mgmt_gw    = cidrhost(azurerm_subnet.mgmt.address_prefix, 1)
  ext_gw     = cidrhost(azurerm_subnet.external.address_prefix, 1)
  int_gw     = cidrhost(azurerm_subnet.internal.address_prefix, 1)
}
# Create UDRs
 resource azurerm_route_table vdms_udr {
  name = "${var.projectPrefix}_vdms_user_defined_route_table"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  disable_bgp_route_propagation = false

 }

 resource azurerm_route_table ips_udr {
  count           = var.deploymentType == "three_tier" ? 1 : 0
  name = "${var.projectPrefix}_ips_user_defined_route_table"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  disable_bgp_route_propagation = false

 }

 resource azurerm_route vdms_to_outbound {
    name                   = "vdms_default_route"
    resource_group_name  = azurerm_resource_group.main.name

    route_table_name       = azurerm_route_table.vdms_udr.name
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.f5vm01int
    # this route should actually point to egress IP / ILB
 }

 resource azurerm_route internaltoips {
  count           = var.deploymentType == "three_tier" ? 1 : 0
   name                 = "internal_to_ips"
   resource_group_name  = azurerm_resource_group.main.name

   route_table_name     = azurerm_route_table.ips_udr[count.index].name
   address_prefix       = var.subnets["internal"]
   next_hop_type        = "VirtualAppliance"
   next_hop_in_ip_address = var.ips01ext
 }

 resource azurerm_subnet_route_table_association udr_associate {
  subnet_id = azurerm_subnet.vdms.id
  route_table_id = azurerm_route_table.vdms_udr.id
 }

 resource azurerm_subnet_route_table_association ips_associate {
   count           = var.deploymentType == "three_tier" ? 1 : 0
   subnet_id            = azurerm_subnet.inspect_external[count.index].id
   route_table_id       = azurerm_route_table.ips_udr[count.index].id 
 }
