# Configure the Microsoft Azure Provider, replace Service Principal and Subscription with your own
provider "azurerm" {
  version = "=1.44.0"
}

# Create a Resource Group for the new Virtual Machines
resource "azurerm_resource_group" "main" {
  name     = "${var.projectPrefix}_rg"
  location = "${var.location}"
}

# Create a Virtual Network within the Resource Group
resource "azurerm_virtual_network" "main" {
  name                = "${var.projectPrefix}-network"
  address_space       = ["${var.cidr}"]
  resource_group_name = "${azurerm_resource_group.main.name}"
  location            = "${azurerm_resource_group.main.location}"
}

# Create the Management Subnet within the Virtual Network
resource "azurerm_subnet" "mgmt" {
  name                 = "mgmt"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  address_prefix       = "${var.subnets["subnet1"]}"
}

# Create the external Subnet within the Virtual Network
resource "azurerm_subnet" "external" {
  name                 = "external"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  address_prefix       = "${var.subnets["subnet2"]}"
}

# Create the internal Subnet within the Virtual Network
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  address_prefix       = "${var.subnets["subnet3"]}"
}

# Obtain Gateway IP for each Subnet
locals {
  depends_on = ["azurerm_subnet.mgmt", "azurerm_subnet.external"]
  mgmt_gw    = "${cidrhost(azurerm_subnet.mgmt.address_prefix, 1)}"
  ext_gw     = "${cidrhost(azurerm_subnet.external.address_prefix, 1)}"
  int_gw     = "${cidrhost(azurerm_subnet.internal.address_prefix, 1)}"
}

# Create a Public IP for the Virtual Machines
resource "azurerm_public_ip" "lbpip" {
  name                         = "${var.projectPrefix}-lb-pip"
  location                     = "${azurerm_resource_group.main.location}"
  resource_group_name          = "${azurerm_resource_group.main.name}"
  allocation_method = "Dynamic"
  domain_name_label            = "${var.projectPrefix}lbpip"
}

# Create Availability Set
resource "azurerm_availability_set" "avset" {
  name                         = "${var.projectPrefix}avset"
  location                     = "${azurerm_resource_group.main.location}"
  resource_group_name          = "${azurerm_resource_group.main.name}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

# Create Azure LB
resource "azurerm_lb" "lb" {
  name                = "${var.projectPrefix}lb"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = "${azurerm_public_ip.lbpip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  name                = "BackendPool1"
  resource_group_name = "${azurerm_resource_group.main.name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
}

resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name = "${azurerm_resource_group.main.name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "tcpProbe"
  protocol            = "tcp"
  port                = 443
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "https_rule" {
  name                           = "HTTPRule"
  resource_group_name            = "${azurerm_resource_group.main.name}"
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  protocol                       = "tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.lb_probe.id}"
  depends_on                     = [azurerm_lb_probe.lb_probe]
}

resource "azurerm_lb_rule" "ssh_rule" {
  name                           = "SSHRule"
  resource_group_name            = "${azurerm_resource_group.main.name}"
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  protocol                       = "tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.lb_probe.id}"
  depends_on                     = [azurerm_lb_probe.lb_probe]
}
resource "azurerm_lb_rule" "rdp_rule" {
  name                           = "RDPRule"
  resource_group_name            = "${azurerm_resource_group.main.name}"
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  protocol                       = "tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.lb_probe.id}"
  depends_on                     = [azurerm_lb_probe.lb_probe]
}

# Create a Network Security Group with some rules
resource "azurerm_network_security_group" "main" {
  name                = "${var.projectPrefix}-nsg"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  security_rule {
    name                       = "allow_SSH"
    description                = "Allow SSH access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_HTTP"
    description                = "Allow HTTP access"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_HTTPS"
    description                = "Allow HTTPS access"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_RDP"
    description                = "Allow RDP access"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_APP_HTTPS"
    description                = "Allow HTTPS access"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Name           = "${var.environment}-bigip-sg"
    environment    = "${var.environment}"
    owner          = "${var.owner}"
    group          = "${var.group}"
    costcenter     = "${var.costcenter}"
    application    = "${var.application}"
  }
}

# Single Tier
#
# Deploy firewall HA cluster
module "firewall" {
#   source   = "./${var.deploymentType}/firewall"
  source   = "./single_tier/firewall"
  resourceGroup = "${azurerm_resource_group.main}"
  sshPublicKey = "${var.sshPublicKeyPath}"
  region = "${var.region}"
  subnetMgmt = "${azurerm_subnet.mgmt}"
  subnetExternal = "${azurerm_subnet.external}"
  subnetInternal = "${azurerm_subnet.internal}"
  securityGroup = "${azurerm_network_security_group.main}"
  owner = "${var.owner}"
  templates = "/workspace/templates"
  adminUserName = "${var.adminUserName}"
  adminPassword = "${var.adminPassword}"
  prefix = "${var.projectPrefix}"
  backendPool = "${azurerm_lb_backend_address_pool.backend_pool}"
  availabilitySet = "${azurerm_availability_set.avset}"
}

# deploy demo app
module "app" {
  #source   = "./${var.deploymentType}/app"
  source   = "./single_tier/app"
  resourceGroup = "${azurerm_resource_group.main}"
#   ssh_publickey = "${var.sshPublicKeyPath}"
  prefix = "${var.projectPrefix}"
  securityGroup = "${azurerm_network_security_group.main}"
  subnetExternal = "${azurerm_subnet.external}"
  templates = "/workspace/templates"
  adminUserName = "${var.adminUserName}"
  adminPassword = "${var.adminPassword}"
}
# deploy jumpboxes
module "jump" {
#   source   = "./${var.deploymentType}/firewall"
  source   = "./single_tier/jumpboxes"
  resourceGroup = "${azurerm_resource_group.main}"
  sshPublicKey = "${var.sshPublicKeyPath}"
  region = "${var.region}"
  subnetExternal = "${azurerm_subnet.external}"
  securityGroup = "${azurerm_network_security_group.main}"
  owner = "${var.owner}"
  templates = "/workspace/templates"
  adminUserName = "${var.adminUserName}"
  adminPassword = "${var.adminPassword}"
  prefix = "${var.projectPrefix}"
}

# #
# # Three Tier
# #
# # Deploy firewall HA cluster
# module "firewall" {
# #   source   = "./${var.deploymentType}/firewall"
#   source   = "./three_tier/firewall"
#   resourceGroup = "${azurerm_resource_group.main}"
#   f5_ssh_publickey = "${var.sshPublicKeyPath}"
#   AllowedIPs = "${var.AllowedIPs}"
#   azure_region ="${var.region}"
#   subnet1_public_id = "${azurerm_subnet.azurerm_publicsubnet1.id}"
#   owner = "${var.owner}"
#   templates = "${template_dir.templates.source_dir}"
# }
# # Deploy example ips
# module "ips" {
# #   source   = "./${var.deploymentType}/ips"
#   source   = "./three_tier/ips"
#    resourceGroup = "${azurerm_resource_group.main}"
#   templates = "${template_dir.templates.source_dir}"
# }
# # Deploy waf HA cluster
# module "waf" {
# #   source   = "./${var.deploymentType}/waf"
#   source   = "./three_tier/waf"
#    resourceGroup = "${azurerm_resource_group.main}"
#   f5_ssh_publickey = "${var.sshPublicKeyPath}"
#   AllowedIPs = "${var.AllowedIPs}"
#   azure_region ="${var.region}"
#   subnet1_public_id = "${azurerm_subnet.azurerm_publicsubnet1.id}"
#   owner = "${var.owner}"
#   templates = "${template_dir.templates.source_dir}"
# }
# # deploy demo app

# module "app" {
#   #source   = "./${var.deploymentType}/app"
#   source   = "./single_tier/app"
#    resourceGroup = "${azurerm_resource_group.main}"
# #   ssh_publickey = "${var.sshPublicKeyPath}"
#   templates = "${template_dir.templates.source_dir}"
# }