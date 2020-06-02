# Create Availability Set
resource azurerm_availability_set avset {
  name                         = "${var.projectPrefix}avset"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

# Create Azure LB
resource azurerm_lb lb {
  name                = "${var.projectPrefix}lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.lbpip.id
  }
}

resource azurerm_lb_backend_address_pool backend_pool {
  name                = "BackendPool1"
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.lb.id
}

resource azurerm_lb_probe lb_probe {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "tcpProbe"
  protocol            = "tcp"
  port                = 443
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource azurerm_lb_rule https_rule {
  name                           = "HTTPRule"
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = azurerm_lb_backend_address_pool.backend_pool.id
  idle_timeout_in_minutes        = 5
  probe_id                       = azurerm_lb_probe.lb_probe.id
  depends_on                     = [azurerm_lb_probe.lb_probe]
}

resource azurerm_lb_rule ssh_rule {
  name                           = "SSHRule"
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = azurerm_lb_backend_address_pool.backend_pool.id
  idle_timeout_in_minutes        = 5
  probe_id                       = azurerm_lb_probe.lb_probe.id
  depends_on                     = [azurerm_lb_probe.lb_probe]
}
resource azurerm_lb_rule rdp_rule {
  name                           = "RDPRule"
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = azurerm_lb_backend_address_pool.backend_pool.id
  idle_timeout_in_minutes        = 5
  probe_id                       = azurerm_lb_probe.lb_probe.id
  depends_on                     = [azurerm_lb_probe.lb_probe]
}



# Single Tier
#
# Deploy firewall HA cluster
module firewall {
#   source   = "./${var.deploymentType}/firewall"
  source   = "./single_tier/firewall"
  resourceGroup = azurerm_resource_group.main
  sshPublicKey = var.sshPublicKeyPath
  region = var.region
  subnetMgmt = azurerm_subnet.mgmt
  subnetExternal = azurerm_subnet.external
  subnetInternal = azurerm_subnet.internal
  securityGroup = azurerm_network_security_group.main
  owner = var.owner
  adminUserName = var.adminUserName
  adminPassword = var.adminPassword
  prefix = var.projectPrefix
  backendPool = azurerm_lb_backend_address_pool.backend_pool
  availabilitySet = azurerm_availability_set.avset
  instanceType = var.instanceType
}

# deploy demo app
module app {
  #source   = "./${var.deploymentType}/app"
  source   = "./single_tier/app"
  resourceGroup = azurerm_resource_group.main
#   ssh_publickey = var.sshPublicKeyPath}"
  prefix = var.projectPrefix
  securityGroup = azurerm_network_security_group.main
  subnetExternal = azurerm_subnet.external
  adminUserName = var.adminUserName
  adminPassword = var.adminPassword
}
# deploy jumpboxes
module jump {
#   source   = "./${var.deploymentType}/firewall"
  source   = "./single_tier/jumpboxes"
  resourceGroup = azurerm_resource_group.main
  sshPublicKey = var.sshPublicKeyPath
  region = var.region
  subnetExternal = azurerm_subnet.external
  securityGroup = azurerm_network_security_group.main
  owner = var.owner
  adminUserName = var.adminUserName
  adminPassword = var.adminPassword
  prefix = var.projectPrefix
}

# #
# # Three Tier
# #
# # Deploy firewall HA cluster
# module "firewall" {
# #   source   = "./${var.deploymentType}/firewall"
#   source   = "./three_tier/firewall"
#   resourceGroup = azurerm_resource_group.main
#   f5_ssh_publickey = var.sshPublicKeyPath
#   AllowedIPs = var.AllowedIPs
#   azure_region =var.region
#   subnet1_public_id = azurerm_subnet.azurerm_publicsubnet1.id
#   owner = var.owner
#   templates = template_dir.templates.source_dir
# }
# # Deploy example ips
# module "ips" {
# #   source   = "./${var.deploymentType}/ips"
#   source   = "./three_tier/ips"
#    resourceGroup = azurerm_resource_group.main
#   templates = template_dir.templates.source_dir
# }
# # Deploy waf HA cluster
# module "waf" {
# #   source   = "./${var.deploymentType}/waf"
#   source   = "./three_tier/waf"
#    resourceGroup = azurerm_resource_group.main
#   f5_ssh_publickey = var.sshPublicKeyPath
#   AllowedIPs = var.AllowedIPs
#   azure_region =var.region
#   subnet1_public_id = azurerm_subnet.azurerm_publicsubnet1.id
#   owner = var.owner
#   templates = template_dir.templates.source_dir
# }
# # deploy demo app

# module "app" {
#   #source   = "./${var.deploymentType}/app"
#   source   = "./single_tier/app"
#    resourceGroup = azurerm_resource_group.main
# #   ssh_publickey = var.sshPublicKeyPath
#   templates = template_dir.templates.source_dir
# }