variable resourceGroup { }
# admin credentials
variable adminUserName { default = "admin" }
variable adminPassword { default = "2017F5Networks!!" }
variable sshPublicKey { default = "/mykey.pub" }
# cloud info
variable region { }
variable securityGroup {
  default = "none"
}
variable availabilitySet {
  
}

variable subnets { }

variable prefix { }
# bigip network
variable subnetMgmt { }
variable subnetExternal { }
variable subnetInternal { }
variable backendPool {  
  description = "azureLB resource pool"
}

# bigip mgmt private ips
variable f5vm01mgmt { }
variable f5vm02mgmt {  }

# bigip external private ips
variable f5vm01ext {  }
variable f5vm01ext_sec {  }
variable f5vm02ext {  }
variable f5vm02ext_sec {  }

# Example application private ips
variable app01ext {  }

# bigip internal private ips 
variable f5vm01int {  }
variable f5vm02int {  }

# winjump
variable winjumpip {  }

# linuxjump
variable linuxjumpip {  }

# device
variable instanceType {  }


# BIGIP Image
variable image_name { default = "f5-bigip-virtual-edition-25m-best-hourly" }
variable product { default = "f5-big-ip-best" }
variable bigip_version { default = "latest" }

# BIGIP Setup
variable licenses {
  type = map(string)
  default = {
    license1 = ""
    "license2" = ""
    "license3" = ""
    "license4" = ""
  }
}
variable license1 { default = "" }
variable license2 { default = "" }
variable host1_name {  }
variable host2_name {  }
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