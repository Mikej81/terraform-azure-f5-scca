variable resourceGroup {}
# admin credentials
variable adminUserName { default = "" }
variable adminPassword { default = "" }
variable sshPublicKey { default = "" }
# cloud info
variable location {}
variable region {}
variable securityGroup {
  default = "none"
}
variable availabilitySet {}
variable availabilitySet2 {}

variable subnets {}

variable prefix {}
# bigip network
variable subnetMgmt {}
variable subnetExternal {}
variable subnetInternal {}
variable backendPool {
  description = "azureLB resource pool"
}
variable managementPool {}
variable primaryPool {}

# bigip mgmt private ips
variable f5vm01mgmt {}
variable f5vm02mgmt {}

# bigip external private ips
variable f5vm01ext {}
variable f5vm01ext_sec {}
variable f5vm02ext {}
variable f5vm02ext_sec {}

# Example application private ips
variable app01ip {}

variable ilb01ip {}

# bigip internal private ips
variable f5vm01int {}
variable f5vm01int_sec {}
variable f5vm02int {}
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
variable host1_name {}
variable host2_name {}
variable dns_server { default = "8.8.8.8" }
variable ntp_server { default = "0.us.pool.ntp.org" }
variable timezone { default = "UTC" }
variable onboard_log { default = "/var/log/startup-script.log" }
## ASM Policy
##  -Examples:  https://github.com/f5devcentral/f5-asm-policy-templates
##  -Default is using OWASP Ready Autotuning
variable asm_policy {}


# TAGS
variable purpose { default = "public" }
variable environment { default = "f5env" } #ex. dev/staging/prod
variable owner { default = "f5owner" }
variable group { default = "f5group" }
variable costcenter { default = "f5costcenter" }
variable application { default = "f5app" }
