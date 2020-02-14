# Create the first network interface card for Management 
resource "azurerm_network_interface" "vm01-mgmt-nic" {
  name                      = "${var.prefix}-vm01-mgmt-nic"
  location                  = "${var.resourceGroup.main.location}"
  resource_group_name       = "${var.resourceGroup.main.name}"
  network_security_group_id = "${azurerm_network_security_group.main.id}"

  ip_configuration {
    name                          = "primary"
    subnet_id                     = "${azurerm_subnet.mgmt.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.f5vm01mgmt}"
    public_ip_address_id          = "${azurerm_public_ip.f5vmpip01.id}"
  }

  tags = {
    Name           = "${var.environment}-vm01-mgmt-int"
    environment    = "${var.environment}"
    owner          = "${var.owner}"
    group          = "${var.group}"
    costcenter     = "${var.costcenter}"
    application    = "${var.application}"
  }
}

resource "azurerm_network_interface" "vm02-mgmt-nic" {
  name                      = "${var.prefix}-vm02-mgmt-nic"
  location                  = "${var.resourceGroup.main.location}"
  resource_group_name       = "${var.resourceGroup.main.name}"
  network_security_group_id = "${azurerm_network_security_group.main.id}"

  ip_configuration {
    name                          = "primary"
    subnet_id                     = "${azurerm_subnet.mgmt.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.f5vm02mgmt}"
    public_ip_address_id          = "${azurerm_public_ip.f5vmpip02.id}"
  }

  tags = {
    Name           = "${var.environment}-vm02-mgmt-int"
    environment    = "${var.environment}"
    owner          = "${var.owner}"
    group          = "${var.group}"
    costcenter     = "${var.costcenter}"
    application    = "${var.application}"
  }
}

# Create the second network interface card for External
resource "azurerm_network_interface" "vm01-ext-nic" {
  name                = "${var.prefix}-vm01-ext-nic"
  location            = "${var.resourceGroup.main.location}"
  resource_group_name = "${var.resourceGroup.main.name}"
  network_security_group_id = "${azurerm_network_security_group.main.id}"
  depends_on          = ["azurerm_lb_backend_address_pool.backend_pool"]
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "primary"
    subnet_id                     = "${azurerm_subnet.External.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.f5vm01ext}"
    primary			  = true
  }

  ip_configuration {
    name                          = "secondary"
    subnet_id                     = "${azurerm_subnet.External.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.f5vm01ext_sec}"
  }

  tags = {
    Name           = "${var.environment}-vm01-ext-int"
    environment    = "${var.environment}"
    owner          = "${var.owner}"
    group          = "${var.group}"
    costcenter     = "${var.costcenter}"
    application    = "${var.application}"
    f5_cloud_failover_label = "saca"
    f5_cloud_failover_nic_map = "external"
  }
}

resource "azurerm_network_interface" "vm02-ext-nic" {
  name                = "${var.prefix}-vm02-ext-nic"
  location            = "${var.resourceGroup.main.location}"
  resource_group_name = "${var.resourceGroup.main.name}"
  network_security_group_id = "${azurerm_network_security_group.main.id}"
  depends_on          = ["azurerm_lb_backend_address_pool.backend_pool"]
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "primary"
    subnet_id                     = "${azurerm_subnet.External.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.f5vm02ext}"
    primary			  = true
  }

  ip_configuration {
    name                          = "secondary"
    subnet_id                     = "${azurerm_subnet.External.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.f5vm02ext_sec}"
  }

  tags = {
    Name           = "${var.environment}-vm01-ext-int"
    environment    = "${var.environment}"
    owner          = "${var.owner}"
    group          = "${var.group}"
    costcenter     = "${var.costcenter}"
    application    = "${var.application}"
    f5_cloud_failover_label = "saca"
    f5_cloud_failover_nic_map = "external"
  }
}
# Create the third network interface card for Internal
resource "azurerm_network_interface" "vm01-int-nic" {
  name                = "${var.prefix}-vm01-int-nic"
  location            = "${var.resourceGroup.main.location}"
  resource_group_name = "${var.resourceGroup.main.name}"
  network_security_group_id = "${azurerm_network_security_group.main.id}"
  #depends_on          = ["azurerm_lb_backend_address_pool.backend_pool"]
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "primary"
    subnet_id                     = "${azurerm_subnet.Internal.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.f5vm01int}"
    primary			  = true
  }

  tags = {
    Name           = "${var.environment}-vm01-int-int"
    environment    = "${var.environment}"
    owner          = "${var.owner}"
    group          = "${var.group}"
    costcenter     = "${var.costcenter}"
    application    = "${var.application}"
  }
}

resource "azurerm_network_interface" "vm02-int-nic" {
  name                = "${var.prefix}-vm02-int-nic"
  location            = "${var.resourceGroup.main.location}"
  resource_group_name = "${var.resourceGroup.main.name}"
  network_security_group_id = "${azurerm_network_security_group.main.id}"
  #depends_on          = ["azurerm_lb_backend_address_pool.backend_pool"]
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "primary"
    subnet_id                     = "${azurerm_subnet.Internal.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.f5vm02int}"
    primary			  = true
  }

  tags = {
    Name           = "${var.environment}-vm02-int-int"
    environment    = "${var.environment}"
    owner          = "${var.owner}"
    group          = "${var.group}"
    costcenter     = "${var.costcenter}"
    application    = "${var.application}"
  }
}
# Associate the Network Interface to the BackendPool
resource "azurerm_network_interface_backend_address_pool_association" "bpool_assc_vm01" {
  depends_on          = ["azurerm_lb_backend_address_pool.backend_pool", "azurerm_network_interface.vm01-ext-nic"]
  network_interface_id    = "${azurerm_network_interface.vm01-ext-nic.id}"
  ip_configuration_name   = "secondary"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.backend_pool.id}"
}

resource "azurerm_network_interface_backend_address_pool_association" "bpool_assc_vm02" {
  depends_on          = ["azurerm_lb_backend_address_pool.backend_pool", "azurerm_network_interface.vm02-ext-nic"]
  network_interface_id    = "${azurerm_network_interface.vm02-ext-nic.id}"
  ip_configuration_name   = "secondary"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.backend_pool.id}"
}

# Create F5 BIGIP VMs
resource "azurerm_virtual_machine" "f5vm01" {
  name                         = "${var.prefix}-f5vm01"
  location                     = "${var.resourceGroup.main.location}"
  resource_group_name          = "${var.resourceGroup.main.name}"
  primary_network_interface_id = "${azurerm_network_interface.vm01-mgmt-nic.id}"
  network_interface_ids        = ["${azurerm_network_interface.vm01-mgmt-nic.id}", "${azurerm_network_interface.vm01-ext-nic.id}", "${azurerm_network_interface.vm01-int-nic.id}"]
  vm_size                      = "${var.instance_type}"
  availability_set_id          = "${azurerm_availability_set.avset.id}"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
   delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
   delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "f5-networks"
    offer     = "${var.product}"
    sku       = "${var.image_name}"
    version   = "${var.bigip_version}"
  }

  storage_os_disk {
    name              = "${var.prefix}vm01-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix}vm01"
    admin_username = "${var.uname}"
    admin_password = "${var.upassword}"
    custom_data    = "${data.template_file.vm_onboard.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  plan {
    name          = "${var.image_name}"
    publisher     = "f5-networks"
    product       = "${var.product}"
  }

  tags = {
    Name           = "${var.environment}-f5vm01"
    environment    = "${var.environment}"
    owner          = "${var.owner}"
    group          = "${var.group}"
    costcenter     = "${var.costcenter}"
    application    = "${var.application}"
  }
}

resource "azurerm_virtual_machine" "f5vm02" {
  name                         = "${var.prefix}-f5vm02"
  location                     = "${var.resourceGroup.main.location}"
  resource_group_name          = "${var.resourceGroup.main.name}"
  primary_network_interface_id = "${azurerm_network_interface.vm02-mgmt-nic.id}"
  network_interface_ids        = ["${azurerm_network_interface.vm02-mgmt-nic.id}", "${azurerm_network_interface.vm02-ext-nic.id}", "${azurerm_network_interface.vm02-int-nic.id}"]
  vm_size                      = "${var.instance_type}"
  availability_set_id          = "${azurerm_availability_set.avset.id}"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "f5-networks"
    offer     = "${var.product}"
    sku       = "${var.image_name}"
    version   = "${var.bigip_version}"
  }

  storage_os_disk {
    name              = "${var.prefix}vm02-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix}vm02"
    admin_username = "${var.uname}"
    admin_password = "${var.upassword}"
    custom_data    = "${data.template_file.vm_onboard.rendered}"
}

  os_profile_linux_config {
    disable_password_authentication = false
  }

  plan {
    name          = "${var.image_name}"
    publisher     = "f5-networks"
    product       = "${var.product}"
  }

  tags = {
    Name           = "${var.environment}-f5vm02"
    environment    = "${var.environment}"
    owner          = "${var.owner}"
    group          = "${var.group}"
    costcenter     = "${var.costcenter}"
    application    = "${var.application}"
  }
}

# Setup Onboarding scripts
data "template_file" "vm_onboard" {
  template = "${file("${path.module}/onboard.tpl")}"

  vars = {
    uname        	      = "${var.uname}"
    upassword        	  = "${var.upassword}"
    doVersion             = "latest"
    #example version:
    #as3Version            = "3.16.0"
    as3Version            = "latest"
    tsVersion             = "latest"
    cfVersion             = "latest"
    doExternalDeclarationUrl = "https://example.domain.com/do.json"
    as3ExternalDeclarationUrl = "https://example.domain.com/as3.json"
    tsExternalDeclarationUrl = "https://example.domain.com/ts.json"
    cfExternalDeclarationUrl = "https://example.domain.com/cf.json"
    DO_onboard_URL      = "${var.DO_onboard_URL}"
    AS3_URL		          = "${var.AS3_URL}"
    libs_dir		        = "${var.libs_dir}"
    onboard_log		      = "${var.onboard_log}"
    DO1_Document        = "${data.template_file.vm01_do_json.rendered}"
    DO2_Document        = "${data.template_file.vm02_do_json.rendered}"
    AS3_Document        = "${data.template_file.as3_json.rendered}"
  }
}

# template ATC json


# as3 uuid generation
resource "random_uuid" "as3_uuid" { }

data "template_file" "vm01_do_json" {
  template = "${file("${path.module}/cluster.json")}"

  vars = {
    #Uncomment the following line for BYOL
    #local_sku	    = "${var.license1}"

    host1	    = "${var.host1_name}"
    host2	    = "${var.host2_name}"
    local_host      = "${var.host1_name}"
    local_selfip    = "${var.f5vm01ext}"
    remote_host	    = "${var.host2_name}"
    remote_selfip   = "${var.f5vm02ext}"
    gateway	    = "${local.ext_gw}"
    dns_server	    = "${var.dns_server}"
    ntp_server	    = "${var.ntp_server}"
    timezone	    = "${var.timezone}"
    admin_user      = "${var.uname}"
    admin_password  = "${var.upassword}"
  }
}

data "template_file" "vm02_do_json" {
  template = "${file("${path.module}/cluster.json")}"

  vars = {
    #Uncomment the following line for BYOL
    #local_sku      = "${var.license2}"

    host1           = "${var.host1_name}"
    host2           = "${var.host2_name}"
    local_host      = "${var.host2_name}"
    local_selfip    = "${var.f5vm02ext}"
    remote_host     = "${var.host1_name}"
    remote_selfip   = "${var.f5vm01ext}"
    gateway         = "${local.ext_gw}"
    dns_server      = "${var.dns_server}"
    ntp_server      = "${var.ntp_server}"
    timezone        = "${var.timezone}"
    admin_user      = "${var.uname}"
    admin_password  = "${var.upassword}"
  }
}

data "template_file" "as3_json" {
  template = "${file("${path.module}/scca.json")}"
  vars ={
      uuid = "${random_uuid.as3_uuid.result}"
  }
}

# Run Startup Script
resource "azurerm_virtual_machine_extension" "f5vm01-run-startup-cmd" {
  name                 = "${var.environment}-f5vm01-run-startup-cmd"
  depends_on           = ["azurerm_virtual_machine.f5vm01", "azurerm_virtual_machine.backendvm"]
  location             = "${var.region}"
  resource_group_name  = "${var.resourceGroup.main.name}"
  virtual_machine_name = "${azurerm_virtual_machine.f5vm01.name}"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "bash /var/lib/waagent/CustomData 1"
    }
  SETTINGS

  tags = {
    Name           = "${var.environment}-f5vm01-startup-cmd"
    environment    = "${var.environment}"
    owner          = "${var.owner}"
    group          = "${var.group}"
    costcenter     = "${var.costcenter}"
    application    = "${var.application}"
  }
}

resource "azurerm_virtual_machine_extension" "f5vm02-run-startup-cmd" {
  name                 = "${var.environment}-f5vm02-run-startup-cmd"
  depends_on           = ["azurerm_virtual_machine.f5vm02", "azurerm_virtual_machine.backendvm"]
  location             = "${var.region}"
  resource_group_name  = "${var.resourceGroup.main.name}"
  virtual_machine_name = "${azurerm_virtual_machine.f5vm02.name}"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "bash /var/lib/waagent/CustomData 2"
    }
  SETTINGS

  tags = {
    Name           = "${var.environment}-f5vm02-startup-cmd"
    environment    = "${var.environment}"
    owner          = "${var.owner}"
    group          = "${var.group}"
    costcenter     = "${var.costcenter}"
    application    = "${var.application}"
  }
}


# Debug Template Outputs
resource "local_file" "vm01_do_file" {
  content     = "${data.template_file.vm01_do_json.rendered}"
  filename    = "${path.module}/vm01_do_data.json"
}

resource "local_file" "vm02_do_file" {
  content     = "${data.template_file.vm02_do_json.rendered}"
  filename    = "${path.module}/vm02_do_data.json"
}

resource "local_file" "vm_as3_file" {
  content     = "${data.template_file.as3_json.rendered}"
  filename    = "${path.module}/vm_as3_data.json"
}