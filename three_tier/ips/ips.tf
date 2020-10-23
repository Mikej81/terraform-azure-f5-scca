resource random_id randomId {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = var.resourceGroup.name
  }
  byte_length = 8
}

resource azurerm_storage_account ips_storageaccount {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = var.resourceGroup.name
  location                 = var.resourceGroup.location
  account_replication_type = "LRS"
  account_tier             = "Standard"

  tags = var.tags
}

resource azurerm_network_interface ips01-mgmt-nic {
  name                = "${var.prefix}-ips01-mgmt-nic"
  location            = var.resourceGroup.location
  resource_group_name = var.resourceGroup.name

  enable_accelerated_networking = true
  enable_ip_forwarding          = true

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnetMgmt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ips01mgmt
    primary                       = true
  }

  tags = var.tags
}

resource azurerm_network_interface ips01-ext-nic {
  name                = "${var.prefix}-ips01-ext-nic"
  location            = var.resourceGroup.location
  resource_group_name = var.resourceGroup.name

  enable_accelerated_networking = true
  enable_ip_forwarding          = true

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnetInspectExt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ips01ext
    primary                       = true
  }

  tags = var.tags
}

# internal network interface for ips vm
resource azurerm_network_interface ips01-int-nic {
  name                = "${var.prefix}-ips01-int-nic"
  location            = var.resourceGroup.location
  resource_group_name = var.resourceGroup.name

  enable_accelerated_networking = true
  enable_ip_forwarding          = true

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnetInspectInt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ips01int
    primary                       = true
  }

  tags = var.tags
}

# network interface for ips vm
resource azurerm_network_interface_security_group_association ips-ext-nsg {
  network_interface_id      = azurerm_network_interface.ips01-ext-nic.id
  network_security_group_id = var.securityGroup.id
}
# network interface for ips vm
resource azurerm_network_interface_security_group_association ips-int-nsg {
  network_interface_id      = azurerm_network_interface.ips01-int-nic.id
  network_security_group_id = var.securityGroup.id
}
# network interface for ips vm
resource azurerm_network_interface_security_group_association ips-mgmt-nsg {
  network_interface_id      = azurerm_network_interface.ips01-mgmt-nic.id
  network_security_group_id = var.securityGroup.id
}

# ips01-VM
resource azurerm_linux_virtual_machine ips01-vm {
  name                = "${var.prefix}-ips01-vm"
  location            = var.resourceGroup.location
  resource_group_name = var.resourceGroup.name

  network_interface_ids = [azurerm_network_interface.ips01-ext-nic.id, azurerm_network_interface.ips01-int-nic.id, azurerm_network_interface.ips01-mgmt-nic.id]
  size                  = var.instanceType

  admin_username                  = var.adminUserName
  admin_password                  = var.adminPassword
  disable_password_authentication = false
  computer_name                   = "${var.prefix}-ips01-vm"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  # custom_data = base64encode("apt-get update -y;")

  # os_profile {
  #   computer_name  = "ips01"
  #   admin_username = var.adminUserName
  #   admin_password = var.adminPassword
  #   custom_data    = <<-EOF
  #             #!/bin/bash
  #             apt-get update -y;
  #             apt-get install -y docker.io;
  #             # snort version
  #             docker run -it --rm satchm0h/alpine-snort3 snort --version;
  #             # snort run
  #             docker run -it --rm satchm0h/alpine-snort3 snort -i eth0
  #             EOF
  # }

  admin_ssh_key {
    username   = var.adminUserName
    public_key = file("~/.ssh/id_rsa.pub")
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.ips_storageaccount.primary_blob_endpoint
  }

  tags = var.tags
}

resource azurerm_virtual_machine_extension ips01-vm-run-startup {
  name                 = "ips-run-startup-cmd"
  depends_on           = [azurerm_linux_virtual_machine.ips01-vm]
  virtual_machine_id   = azurerm_linux_virtual_machine.ips01-vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "script": "${base64encode(file("./three_tier/ips/ips.sh"))}"
    }
    SETTINGS

  tags = var.tags
}
