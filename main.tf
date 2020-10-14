terraform {
  required_version = "~> 0.13"
}
# Create Availability Set
resource azurerm_availability_set avset {
  name                         = "${var.projectPrefix}avset"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

# Create Availability Set 2 only for 3 tier tho
resource azurerm_availability_set avset2 {
  name                         = "${var.projectPrefix}avset2"
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
  sku                 = "Standard"

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

resource azurerm_lb_backend_address_pool management_pool {
  name                = "ManagementPool1"
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.lb.id
}

resource azurerm_lb_backend_address_pool primary_pool {
  name                = "PrimaryPool1"
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.lb.id
}

resource azurerm_lb_probe https_probe {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "443Probe"
  protocol            = "tcp"
  port                = 443
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource azurerm_lb_probe http_probe {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "8080Probe"
  protocol            = "tcp"
  port                = 8080
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource azurerm_lb_probe ssh_probe {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "sshProbe"
  protocol            = "tcp"
  port                = 22
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource azurerm_lb_probe rdp_probe {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "rdpProbe"
  protocol            = "tcp"
  port                = 3389
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource azurerm_lb_rule https_rule {
  name                           = "HTTPS_Rule"
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  disable_outbound_snat          = true
  backend_address_pool_id        = azurerm_lb_backend_address_pool.backend_pool.id
  idle_timeout_in_minutes        = 5
  probe_id                       = azurerm_lb_probe.https_probe.id
  depends_on                     = [azurerm_lb_probe.https_probe]
}

resource azurerm_lb_rule http_rule {
  name                           = "HTTPRule"
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  disable_outbound_snat          = true
  backend_address_pool_id        = azurerm_lb_backend_address_pool.backend_pool.id
  idle_timeout_in_minutes        = 5
  probe_id                       = azurerm_lb_probe.http_probe.id
  depends_on                     = [azurerm_lb_probe.http_probe]
}

resource azurerm_lb_rule ssh_rule {
  name                           = "SSH_Rule"
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  disable_outbound_snat          = true
  backend_address_pool_id        = azurerm_lb_backend_address_pool.backend_pool.id
  idle_timeout_in_minutes        = 5
  probe_id                       = azurerm_lb_probe.ssh_probe.id
  depends_on                     = [azurerm_lb_probe.ssh_probe]
}
resource azurerm_lb_rule rdp_rule {
  name                           = "RDP_Rule"
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  disable_outbound_snat          = true
  backend_address_pool_id        = azurerm_lb_backend_address_pool.backend_pool.id
  idle_timeout_in_minutes        = 5
  probe_id                       = azurerm_lb_probe.rdp_probe.id
  depends_on                     = [azurerm_lb_probe.rdp_probe]
}

resource azurerm_lb_outbound_rule egress_rule {
  name                     = "egress_rule"
  resource_group_name      = azurerm_resource_group.main.name
  loadbalancer_id          = azurerm_lb.lb.id
  protocol                 = "All"
  backend_address_pool_id  = azurerm_lb_backend_address_pool.primary_pool.id
  allocated_outbound_ports = "16000"
  enable_tcp_reset         = true
  frontend_ip_configuration {
    name = "LoadBalancerFrontEnd"
  }
}

# Single Tier
#
# Deploy firewall HA cluster
module firewall_one {
  count            = var.deploymentType == "one_tier" ? 1 : 0
  source           = "./one_tier/firewall"
  resourceGroup    = azurerm_resource_group.main
  sshPublicKey     = var.sshPublicKeyPath
  location         = var.location
  region           = var.region
  subnetMgmt       = azurerm_subnet.mgmt
  subnetExternal   = azurerm_subnet.external
  subnetInternal   = azurerm_subnet.internal
  securityGroup    = azurerm_network_security_group.main
  image_name       = var.image_name
  product          = var.product
  bigip_version    = var.bigip_version
  owner            = var.owner
  adminUserName    = var.adminUserName
  adminPassword    = var.adminPassword
  prefix           = var.projectPrefix
  backendPool      = azurerm_lb_backend_address_pool.backend_pool
  managementPool   = azurerm_lb_backend_address_pool.management_pool
  primaryPool      = azurerm_lb_backend_address_pool.primary_pool
  availabilitySet  = azurerm_availability_set.avset
  availabilitySet2 = azurerm_availability_set.avset2
  instanceType     = var.instanceType
  subnets          = var.subnets
  app01ip          = var.app01ip
  host1_name       = var.host1_name
  host2_name       = var.host2_name
  f5vm01mgmt       = var.f5vm01mgmt
  f5vm02mgmt       = var.f5vm02mgmt
  f5vm01ext        = var.f5vm01ext
  f5vm02ext        = var.f5vm02ext
  f5vm01ext_sec    = var.f5vm01ext_sec
  f5vm02ext_sec    = var.f5vm02ext_sec
  f5vm01int        = var.f5vm01int
  f5vm02int        = var.f5vm02int
  f5vm01int_sec    = var.f5vm01int_sec
  f5vm02int_sec    = var.f5vm02int_sec
  winjumpip        = var.winjumpip
  linuxjumpip      = var.linuxjumpip
  licenses         = var.licenses
  ilb01ip          = var.ilb01ip
  asm_policy       = var.asm_policy
}

# deploy demo app
module app_one {
  count         = var.deploymentType == "one_tier" ? 1 : 0
  source        = "./one_tier/app"
  location      = var.location
  region        = var.region
  resourceGroup = azurerm_resource_group.main
  #   ssh_publickey = var.sshPublicKeyPath}"
  prefix        = var.projectPrefix
  securityGroup = azurerm_network_security_group.main
  subnet        = azurerm_subnet.internal
  adminUserName = var.adminUserName
  adminPassword = var.adminPassword
  app01ip       = var.app01ip
}
# deploy jumpboxes
module jump_one {
  count         = var.deploymentType == "one_tier" ? 1 : 0
  source        = "./one_tier/jumpboxes"
  resourceGroup = azurerm_resource_group.main
  sshPublicKey  = var.sshPublicKeyPath
  location      = var.location
  region        = var.region
  subnet        = azurerm_subnet.vdms
  securityGroup = azurerm_network_security_group.main
  owner         = var.owner
  adminUserName = var.adminUserName
  adminPassword = var.adminPassword
  prefix        = var.projectPrefix
  instanceType  = var.jumpinstanceType
  linuxjumpip   = var.linuxjumpip
  winjumpip     = var.winjumpip
}

#
# Three Tier
#
# Deploy firewall HA cluster
module firewall_three {
  count           = var.deploymentType == "three_tier" ? 1 : 0
  source          = "./three_tier/firewall"
  resourceGroup   = azurerm_resource_group.main
  sshPublicKey    = var.sshPublicKeyPath
  location        = var.location
  region          = var.region
  subnetMgmt      = azurerm_subnet.mgmt
  subnetExternal  = azurerm_subnet.external
  subnetInternal  = azurerm_subnet.internal
  securityGroup   = azurerm_network_security_group.main
  owner           = var.owner
  adminUserName   = var.adminUserName
  adminPassword   = var.adminPassword
  prefix          = var.projectPrefix
  backendPool     = azurerm_lb_backend_address_pool.backend_pool
  availabilitySet = azurerm_availability_set.avset
  instanceType    = var.instanceType
  app01ip         = var.app01ip
  subnets         = var.subnets
  licenses        = var.licenses
  asm_policy      = var.asm_policy
}
# Deploy example ips
module ips_three {
  count                = var.deploymentType == "three_tier" ? 1 : 0
  source               = "./three_tier/ips"
  prefix               = var.projectPrefix
  location             = var.location
  region               = var.region
  resourceGroup        = azurerm_resource_group.main
  virtual_network_name = azurerm_virtual_network.main.name
  securityGroup        = azurerm_network_security_group.main
  ips01ext             = var.ips01ext
  ips01int             = var.ips01int
  adminUserName        = var.adminUserName
  adminPassword        = var.adminPassword
  subnets              = var.subnets
}
# Deploy waf HA cluster
module waf_three {
  count           = var.deploymentType == "three_tier" ? 1 : 0
  source          = "./three_tier/waf"
  resourceGroup   = azurerm_resource_group.main
  sshPublicKey    = var.sshPublicKeyPath
  location        = var.location
  region          = var.region
  subnetMgmt      = azurerm_subnet.mgmt
  subnetExternal  = azurerm_subnet.external
  subnetInternal  = azurerm_subnet.internal
  securityGroup   = azurerm_network_security_group.main
  owner           = var.owner
  adminUserName   = var.adminUserName
  adminPassword   = var.adminPassword
  prefix          = var.projectPrefix
  backendPool     = azurerm_lb_backend_address_pool.backend_pool
  availabilitySet = azurerm_availability_set.avset2
  instanceType    = var.instanceType
  subnets         = var.subnets
  licenses        = var.licenses
  asm_policy      = var.asm_policy
}
# deploy demo app

module app_three {
  count         = var.deploymentType == "three_tier" ? 1 : 0
  source        = "./three_tier/app"
  resourceGroup = azurerm_resource_group.main
  location      = var.location
  region        = var.region
  #   ssh_publickey = var.sshPublicKeyPath
  securityGroup  = azurerm_network_security_group.main
  subnetExternal = azurerm_subnet.external
  adminUserName  = var.adminUserName
  adminPassword  = var.adminPassword
  subnets        = var.subnets
  prefix         = var.projectPrefix
}
# deploy jumpboxes
module jump_three {
  count          = var.deploymentType == "three_tier" ? 1 : 0
  source         = "./three_tier/jumpboxes"
  resourceGroup  = azurerm_resource_group.main
  sshPublicKey   = var.sshPublicKeyPath
  location       = var.location
  region         = var.region
  subnetExternal = azurerm_subnet.external
  securityGroup  = azurerm_network_security_group.main
  owner          = var.owner
  adminUserName  = var.adminUserName
  adminPassword  = var.adminPassword
  prefix         = var.projectPrefix
  instanceType   = var.jumpinstanceType
  subnets        = var.subnets
}
