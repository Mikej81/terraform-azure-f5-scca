# Create the ILB for South LB and Egress
resource azurerm_lb internalLoadBalancer {
  name                = "${var.prefix}-internalloadbalancer"
  location            = var.location
  resource_group_name = var.resourceGroup.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "subnetInternal_LoadBalancerFrontEnd"
    subnet_id                     = var.subnetInternal.id
    private_ip_address            = var.ilb01ip
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
  }

  frontend_ip_configuration {
    name                          = "waf_ext_LoadBalancerFrontEnd_Egress"
    subnet_id                     = var.subnetWafExt[0].id
    private_ip_address            = var.ilb02ip
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
  }

  frontend_ip_configuration {
    name                          = "waf_ext_LoadBalancerFrontEnd_Ingress"
    subnet_id                     = var.subnetWafExt[0].id
    private_ip_address            = var.ilb03ip
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
  }
}

# Create the LB Pool for Internal Egress
resource azurerm_lb_backend_address_pool internal_backend_pool {
  name                = "egress_pool"
  resource_group_name = var.resourceGroup.name
  loadbalancer_id     = azurerm_lb.internalLoadBalancer.id
}

# Create the LB Pool for WAF Ingress
resource azurerm_lb_backend_address_pool waf_backend_pool {
  name                = "waf_ingress"
  resource_group_name = var.resourceGroup.name
  loadbalancer_id     = azurerm_lb.internalLoadBalancer.id
}

# attach interfaces to backend pool
resource azurerm_network_interface_backend_address_pool_association int_bpool_assc_vm01 {
  network_interface_id    = azurerm_network_interface.vm01-int-nic.id
  ip_configuration_name   = "secondary"
  backend_address_pool_id = azurerm_lb_backend_address_pool.internal_backend_pool.id
}

resource azurerm_network_interface_backend_address_pool_association int_bpool_assc_vm02 {
  network_interface_id    = azurerm_network_interface.vm02-int-nic.id
  ip_configuration_name   = "secondary"
  backend_address_pool_id = azurerm_lb_backend_address_pool.internal_backend_pool.id
}

resource azurerm_lb_probe internal_tcp_probe {
  resource_group_name = var.resourceGroup.name
  loadbalancer_id     = azurerm_lb.internalLoadBalancer.id
  name                = "${var.prefix}-internal-tcp-probe"
  protocol            = "tcp"
  port                = 34568
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource azurerm_lb_rule internal_all_rule {
  name                           = "internal-all-protocol-ilb-egress"
  resource_group_name            = var.resourceGroup.name
  loadbalancer_id                = azurerm_lb.internalLoadBalancer.id
  protocol                       = "all"
  frontend_port                  = 0
  backend_port                   = 0
  load_distribution              = "SourceIPProtocol"
  frontend_ip_configuration_name = "subnetInternal_LoadBalancerFrontEnd"
  enable_floating_ip             = true
  backend_address_pool_id        = azurerm_lb_backend_address_pool.internal_backend_pool.id
  idle_timeout_in_minutes        = 5
  probe_id                       = azurerm_lb_probe.internal_tcp_probe.id
  depends_on                     = [azurerm_lb_probe.internal_tcp_probe]
}

resource azurerm_lb_rule waf_ext_all_rule {
  name                           = "waf-ext-all-protocol-ilb-egress"
  resource_group_name            = var.resourceGroup.name
  loadbalancer_id                = azurerm_lb.internalLoadBalancer.id
  protocol                       = "all"
  frontend_port                  = 0
  backend_port                   = 0
  load_distribution              = "SourceIPProtocol"
  frontend_ip_configuration_name = "waf_ext_LoadBalancerFrontEnd_Egress"
  enable_floating_ip             = true
  backend_address_pool_id        = azurerm_lb_backend_address_pool.internal_backend_pool.id
  idle_timeout_in_minutes        = 5
  probe_id                       = azurerm_lb_probe.internal_tcp_probe.id
  depends_on                     = [azurerm_lb_probe.internal_tcp_probe]
}

resource azurerm_lb_rule waf_ext_ingress_rule {
  name                           = "waf-ext-all-protocol-ilb-ingress"
  resource_group_name            = var.resourceGroup.name
  loadbalancer_id                = azurerm_lb.internalLoadBalancer.id
  protocol                       = "all"
  frontend_port                  = 0
  backend_port                   = 0
  load_distribution              = "SourceIPProtocol"
  frontend_ip_configuration_name = "waf_ext_LoadBalancerFrontEnd_Ingress"
  enable_floating_ip             = true
  backend_address_pool_id        = azurerm_lb_backend_address_pool.internal_backend_pool.id
  idle_timeout_in_minutes        = 5
  probe_id                       = azurerm_lb_probe.internal_tcp_probe.id
  depends_on                     = [azurerm_lb_probe.internal_tcp_probe]
}
