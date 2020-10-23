# templates directory
variable templates {
  default = "/workspace/templates"
}
variable location {}
variable region {}
variable prefix {}
variable resourceGroup {}
variable securityGroup {
  default = "none"
}

variable subnets {}
variable subnetMgmt {}
variable subnetInspectExt {}
variable subnetInspectInt {}
variable virtual_network_name {}

variable ips01ext {}
variable ips01int {}
variable ips01mgmt {}
variable adminUserName {}
variable adminPassword {}

# device
variable instanceType {}

# TAGS
variable tags {}

variable timezone {}
