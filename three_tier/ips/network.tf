

# Create the external IPS subnet within the Vnet
resource azurerm_subnet inspect_external {
  name                 = "inspect_external"
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resourceGroup.name
  address_prefixes     = [var.subnets["inspect_ext"]]

}
# Create the internal IPS subnet within the Vnet
resource azurerm_subnet inspect_internal {
  name                 = "inspect_internal"
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resourceGroup.name
  address_prefixes     = [var.subnets["inspect_int"]]

}

resource azurerm_route_table ips_udr {
  name                          = "${var.prefix}_ips_user_defined_route_table"
  resource_group_name           = var.resourceGroup.name
  location                      = var.location
  disable_bgp_route_propagation = false

}

resource azurerm_route internaltoips {
  name                = "internal_to_ips"
  resource_group_name = var.resourceGroup.name

  route_table_name       = azurerm_route_table.ips_udr.name
  address_prefix         = var.subnets["internal"]
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ips01ext
}

resource azurerm_subnet_route_table_association ips_associate {
  subnet_id      = azurerm_subnet.inspect_external.id
  route_table_id = azurerm_route_table.ips_udr.id
}
