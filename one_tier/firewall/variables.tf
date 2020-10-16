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
variable availabilitySet {}
variable availabilitySet2 {}

variable subnets {}

variable prefix {}
# bigip network
variable subnetMgmt {}
variable subnetExternal {}
variable subnetInternal {}
variable backendPool {}
variable managementPool {}
variable primaryPool {}

variable app01ip {}

variable ilb01ip {}

variable f5_mgmt {}
variable f5_t1_ext {}
variable f5_t1_int {}

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
variable asm_policy {}


# TAGS
variable tags {}
