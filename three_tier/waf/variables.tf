variable resourceGroup {
  default = ""
}
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
variable availabilitySet {

}

variable prefix {
  default = "scca"
}
# bigip network
variable subnetMgmt {

}
variable subnetExternal {

}
variable subnetInternal {

}
variable backendPool {
  description = "azureLB resource pool"
}

# bigip mgmt private ips
variable f5vm03mgmt { default = "10.90.1.6" }
variable f5vm04mgmt { default = "10.90.1.7" }

# bigip external private ips
variable f5vm03ext { default = "10.90.2.6" }
variable f5vm03ext_sec { default = "10.90.2.13" }
variable f5vm04ext { default = "10.90.2.7" }
variable f5vm04ext_sec { default = "10.90.2.14" }

# Example application private ips
variable app03ext { default = "10.90.2.101" }

# bigip internal private ips
variable f5vm03int { default = "10.90.3.6" }
variable f5vm04int { default = "10.90.3.7" }

# winjump
variable winjumpip { default = "10.90.2.98" }

# linuxjump
variable linuxjumpip { default = "10.90.2.99" }

# device
variable instanceType { default = "Standard_DS5_v2" }


# BIGIP Image
variable image_name { default = "f5-bigip-virtual-edition-25m-best-hourly" }
variable product { default = "f5-big-ip-best" }
variable bigip_version { default = "latest" }

# BIGIP Setup
variable licenses {
  type = map(string)
  default = {
    license1   = ""
    "license2" = ""
    "license3" = ""
    "license4" = ""
  }
}
variable license1 { default = "" }
variable license2 { default = "" }
variable host1_name { default = "f5vm03" }
variable host2_name { default = "f5vm04" }
variable dns_server { default = "8.8.8.8" }
variable ntp_server { default = "0.us.pool.ntp.org" }
variable timezone { default = "UTC" }
variable onboard_log { default = "/var/log/startup-script.log" }
## ASM Policy
##  -Examples:  https://github.com/f5devcentral/f5-asm-policy-templates
##  -Default is using OWASP Ready Autotuning
variable asm_policy { default = "https://raw.githubusercontent.com/f5devcentral/f5-asm-policy-templates/master/owasp_ready_template/owasp-auto-tune-v1.1.xml" }

# TAGS
variable purpose { default = "public" }
variable environment { default = "f5env" } #ex. dev/staging/prod
variable owner { default = "f5owner" }
variable group { default = "f5group" }
variable costcenter { default = "f5costcenter" }
variable application { default = "f5app" }
