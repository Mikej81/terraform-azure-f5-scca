## OUTPUTS ###
#data azurerm_public_ip lbpip {
#  name                = azurerm_public_ip.lbpip.name
#  resource_group_name = azurerm_resource_group.main.name
#}

output sg_id { value = azurerm_network_security_group.main.id }
output sg_name { value = azurerm_network_security_group.main.name }

# output ALB_app1_pip { value = data.azurerm_public_ip.lbpip.ip_address }
output ALB_app1_pip { value = "https://${azurerm_public_ip.lbpip.ip_address}" }

# single tier
output f5vm01_id { value = module.firewall.f5vm01_id  }
output f5vm01_mgmt_private_ip { value = module.firewall.f5vm01_mgmt_private_ip }
output f5vm01_mgmt_public_ip { value = "https://${module.firewall.f5vm01_mgmt_public_ip}" }
output f5vm01_ext_private_ip { value = module.firewall.f5vm01_ext_private_ip }

output f5vm02_id { value = module.firewall.f5vm02_id  }
output f5vm02_mgmt_private_ip { value = module.firewall.f5vm02_mgmt_private_ip }
output f5vm02_mgmt_public_ip { value = "https://${module.firewall.f5vm02_mgmt_public_ip}" }
output f5vm02_ext_private_ip { value = module.firewall.f5vm02_ext_private_ip }

# three tier
