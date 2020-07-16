## OUTPUTS ###
#data azurerm_public_ip lbpip {
#  name                = azurerm_public_ip.lbpip.name
#  resource_group_name = azurerm_resource_group.main.name
#}

output sg_id { value = azurerm_network_security_group.main.id }
output sg_name { value = azurerm_network_security_group.main.name }

# output ALB_app1_pip { value = data.azurerm_public_ip.lbpip.ip_address }
output ALB_app1_pip { value = "https://${azurerm_public_ip.lbpip.ip_address}" }

locals {
    one_tier = {
        f5vm01_id = "${try(module.firewall_one.f5vm01_id, "none")}"
        f5vm01_mgmt_private_ip = "${try(module.firewall_one.f5vm01_mgmt_private_ip, "none")}"
        f5vm01_mgmt_public_ip = "https://${try(module.firewall_one.f5vm01_mgmt_public_ip , "none")}"
        f5vm01_ext_private_ip = "${try(module.firewall_one.f5vm01_ext_private_ip , "none")}"
        #
        f5vm02_id = "${try(module.firewall_one.f5vm02_id, "none")}"
        f5vm02_mgmt_private_ip = "${try(module.firewall_one.f5vm02_mgmt_private_ip, "none")}"
        f5vm02_mgmt_public_ip = "https://${try(module.firewall_one.f5vm02_mgmt_public_ip , "none")}"
        f5vm02_ext_private_ip = "${try(module.firewall_one.f5vm02_ext_private_ip , "none")}"
    }
    three_tier = {
        f5vm01_id = "${try(module.waf_three.f5vm01_id, "none")}"
        f5vm01_mgmt_private_ip = "${try(module.waf_three.f5vm01_mgmt_private_ip, "none")}"
        f5vm01_mgmt_public_ip = "https://${try(module.waf_three.f5vm01_mgmt_public_ip , "none")}"
        f5vm01_ext_private_ip = "${try(module.waf_three.f5vm01_ext_private_ip , "none")}"
        #
        f5vm02_id = "${try(module.waf_three.f5vm02_id, "none")}"
        f5vm02_mgmt_private_ip = "${try(module.waf_three.f5vm02_mgmt_private_ip, "none")}"
        f5vm02_mgmt_public_ip = "https://${try(module.waf_three.f5vm02_mgmt_public_ip , "none")}"
        f5vm02_ext_private_ip = "${try(module.waf_three.f5vm02_ext_private_ip , "none")}"
        #
        f5vm03_id = "${try(module.waf_three.f5vm03_id, "none")}"
        f5vm03_mgmt_private_ip = "${try(module.waf_three.f5vm03_mgmt_private_ip, "none")}"
        f5vm03_mgmt_public_ip = "https://${try(module.waf_three.f5vm03_mgmt_public_ip , "none")}"
        f5vm03_ext_private_ip = "${try(module.waf_three.f5vm03_ext_private_ip , "none")}"
        #
        f5vm04_id = "${try(module.waf_three.f5vm04_id, "none")}"
        f5vm04_mgmt_private_ip = "${try(module.waf_three.f5vm04_mgmt_private_ip, "none")}"
        f5vm04_mgmt_public_ip = "https://${try(module.waf_three.f5vm04_mgmt_public_ip , "none")}"
        f5vm04_ext_private_ip = "${try(module.waf_three.f5vm04_ext_private_ip , "none")}"

          #"${try(odule.waf_three.f5vm04_mgmt_public_ip , "none")}"
    }
}

# single tier
output tier_one { value = local.one_tier }
# three tier
output tier_three { value = local.three_tier }