variable resourceGroup {}
# admin credentials
variable adminUserName {}
variable adminPassword {}
variable sshPublicKey {}
# cloud info
variable location {}
variable region {}
variable securityGroup {
  default = "none"
}
variable availabilitySet {

}

variable prefix {}
# bigip network
variable subnets {}
variable subnetMgmt {}
variable subnetExternal {}
variable subnetInternal {}
variable app01ip {}

variable backendPool {
  description = "azureLB resource pool"
}

# bigip mgmt private ips
variable f5vm01mgmt {}
variable f5vm02mgmt {}
variable f5vm03mgmt {}
variable f5vm04mgmt {}

# bigip external private ips
variable f5vm01ext {}
variable f5vm01ext_sec {}
variable f5vm02ext {}
variable f5vm02ext_sec {}

# bigip internal private ips
variable f5vm01int {}
variable f5vm02int {}
variable f5vm01int_sec {}
variable f5vm02int_sec {}

# winjump
variable winjumpip {}

# linuxjump
variable linuxjumpip {}

# device
variable instanceType {}


# BIGIP Image
variable image_name {}
variable product {}
variable bigip_version {}

# BIGIP Setup
variable licenses {
  type = map(string)
  default = {
    "license1" = ""
    "license2" = ""
    "license3" = ""
    "license4" = ""
  }
}
variable host1_name { default = "f5vm01" }
variable host2_name { default = "f5vm02" }
variable dns_server { default = "8.8.8.8" }
variable ntp_server { default = "0.us.pool.ntp.org" }
variable timezone { default = "UTC" }
variable onboard_log { default = "/var/log/startup-script.log" }
variable asm_policy {}

# TAGS
variable tags {}
