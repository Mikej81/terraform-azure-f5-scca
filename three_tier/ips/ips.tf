# snort ubuntu 16
#https://snort-org-site.s3.amazonaws.com/production/document_files/files/000/000/122/original/Snort_2.9.9.x_on_Ubuntu_14-16.pdf
# network interface for ips vm
resource "azurerm_network_interface_security_group_association" "ips-nsg" {
  network_interface_id      = azurerm_network_interface.ips01-ext-nic.id
  network_security_group_id = var.securityGroup.id
}


resource azurerm_network_interface ips01-ext-nic {
  name                = "${var.prefix}-app01-ext-nic"
  location            = var.resourceGroup.location
  resource_group_name = var.resourceGroup.name

  enable_accelerated_networking = true
  enable_ip_forwarding          = true

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.inspect_external.id
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
    subnet_id                     = azurerm_subnet.inspect_internal.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ips01int
    primary                       = true
  }

  tags = var.tags
}

# ips01-VM
resource azurerm_virtual_machine ips01-vm {
  count               = 1
  name                = "ips01-vm"
  location            = var.resourceGroup.location
  resource_group_name = var.resourceGroup.name

  primary_network_interface_id = azurerm_network_interface.ips01-ext-nic.id
  network_interface_ids        = [azurerm_network_interface.ips01-ext-nic.id, azurerm_network_interface.ips01-int-nic.id]
  vm_size                      = "Standard_DS1_v2"

  storage_os_disk {
    name              = "ipsOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "ips01"
    admin_username = var.adminUserName
    admin_password = var.adminPassword
    custom_data    = <<-EOF
              #!/bin/bash
              apt-get update -y;
              apt-get install -y docker.io;
              # snort version
              docker run -it --rm satchm0h/alpine-snort3 snort --version;
              # snort run
              docker run -it --rm satchm0h/alpine-snort3 snort -i eth0
              EOF
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = var.tags
}
