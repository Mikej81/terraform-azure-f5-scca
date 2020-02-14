# Configure the Microsoft Azure Provider, replace Service Principal and Subscription with your own
provider "azurerm" {
  version = "=1.38.0"
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

# Create the External Subnet within the Virtual Network
resource "azurerm_subnet" "External" {
  name                 = "External"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  address_prefix       = "${var.subnets["subnet2"]}"
}

# Create the Internal Subnet within the Virtual Network
resource "azurerm_subnet" "Internal" {
  name                 = "Internal"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  address_prefix       = "${var.subnets["subnet3"]}"
}

# Obtain Gateway IP for each Subnet
locals {
  depends_on = ["azurerm_subnet.mgmt", "azurerm_subnet.External"]
  mgmt_gw    = "${cidrhost(azurerm_subnet.mgmt.address_prefix, 1)}"
  ext_gw     = "${cidrhost(azurerm_subnet.External.address_prefix, 1)}"
  int_gw     = "${cidrhost(azurerm_subnet.Internal.address_prefix, 1)}"
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
  depends_on                     = ["azurerm_lb_probe.lb_probe"]
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
  depends_on                     = ["azurerm_lb_probe.lb_probe"]
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

# Create a Public IP for the Virtual Machines
resource "azurerm_public_ip" "f5vmpip01" {
  name                = "${var.projectPrefix}-vm01-mgmt-pip01"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  allocation_method   = "Dynamic"

  tags = {
    Name = "${var.projectPrefix}-f5vm-public-ip"
  }
}
resource "azurerm_public_ip" "f5vmpip02" {
  name                = "${var.projectPrefix}-vm02-mgmt-pip02"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  allocation_method   = "Dynamic"

  tags = {
    Name = "${var.projectPrefix}-f5vm-public-ip"
  }
}


# templates
resource "template_dir" "templates" {
  source_dir      = "${path.module}/templates"
  destination_dir = "${path.cwd}/templates"
}
#
# Single Tier
#
# Deploy firewall HA cluster
module "firewall" {
#   source   = "./${var.deploymentType}/firewall"
  source   = "./single_tier/firewall"
  resourceGroup = "${azurerm_resource_group.main}"
  f5_ssh_publickey = "${var.key_path}"
  AllowedIPs = "${var.AllowedIPs}"
  azure_region ="${var.azure_region}"
  subnet1_public_id = "${azurerm_subnet.azurerm_publicsubnet1.id}"
  owner = "${var.owner}"
  templates = "${template_dir.templates.source_dir}"
}

# deploy demo app
module "app" {
  #source   = "./${var.deploymentType}/app"
  source   = "./single_tier/app"
  resourceGroup = "${azurerm_resource_group.main}"
#   ssh_publickey = "${var.key_path}"
  prefix = "${var.projectPrefix}"
  securityGroup = "${azurerm_network_security_group.main}"
  subnetExternal = "${azurerm_subnet.External}"
  templates = "${template_dir.templates.source_dir}"
  adminUserName = "${var.adminUserName}"
  adminPassword = "${var.adminPassword}"
}
# #
# # Three Tier
# #
# # Deploy firewall HA cluster
# module "firewall" {
# #   source   = "./${var.deploymentType}/firewall"
#   source   = "./three_tier/firewall"
#   resourceGroup = "${azurerm_resource_group.main}"
#   f5_ssh_publickey = "${var.key_path}"
#   AllowedIPs = "${var.AllowedIPs}"
#   azure_region ="${var.azure_region}"
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
#   f5_ssh_publickey = "${var.key_path}"
#   AllowedIPs = "${var.AllowedIPs}"
#   azure_region ="${var.azure_region}"
#   subnet1_public_id = "${azurerm_subnet.azurerm_publicsubnet1.id}"
#   owner = "${var.owner}"
#   templates = "${template_dir.templates.source_dir}"
# }
# # deploy demo app

# module "app" {
#   #source   = "./${var.deploymentType}/app"
#   source   = "./single_tier/app"
#    resourceGroup = "${azurerm_resource_group.main}"
# #   ssh_publickey = "${var.key_path}"
#   templates = "${template_dir.templates.source_dir}"
# }