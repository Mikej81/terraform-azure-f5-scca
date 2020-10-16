# Azure Environment
variable projectPrefix {
  type        = string
  description = "REQUIRED: Prefix to prepend to all objects created, minus Windows Jumbox"
  default     = "mcscca"
}
variable adminUserName {
  type        = string
  description = "REQUIRED: Admin Username for All systems"
  default     = "xadmin"
}
variable adminPassword {
  type        = string
  description = "REQUIRED: Admin Password for all systems"
  default     = "pleaseUseVault123!!"
}
variable location {
  type        = string
  description = "REQUIRED: Azure Region: usgovvirginia, usgovarizona, etc"
  default     = "usgovvirginia"
}
variable region {
  type        = string
  description = "Azure Region: US Gov Virginia, US Gov Arizona, etc"
  default     = "USGov Virginia"
}
variable deploymentType {
  type        = string
  description = "REQUIRED: This determines the type of deployment; one tier versus three tier: one_tier, three_tier"
  default     = "one_tier"
}
variable sshPublicKey {
  type        = string
  description = "OPTIONAL: ssh public key for instances"
  default     = ""
}
variable sshPublicKeyPath {
  type        = string
  description = "OPTIONAL: ssh public key path for instances"
  default     = "/mykey.pub"
}

# NETWORK
variable cidr {
  description = "REQUIRED: VNET Network CIDR"
  default     = "10.90.0.0/16"
}
variable subnets {
  type        = map(string)
  description = "REQUIRED: Subnet CIDRs"
  default = {
    "management"  = "10.90.0.0/24"
    "external"    = "10.90.1.0/24"
    "internal"    = "10.90.2.0/24"
    "vdms"        = "10.90.3.0/24"
    "inspect_ext" = "10.90.4.0/24"
    "inspect_int" = "10.90.5.0/24"
    "waf_ext"     = "10.90.6.0/24"
    "waf_int"     = "10.90.7.0/24"
  }
}

variable f5mgmt {
  description = "F5 BIG-IP Management IPs.  These must be in the management subnet."
  type        = map(string)
  default = {
    f5vm01mgmt = "10.90.0.4"
    f5vm02mgmt = "10.90.0.5"
    f5vm03mgmt = "10.90.0.6"
    f5vm04mgmt = "10.90.0.7"
  }

}

# bigip external private ips, these must be in external subnet
variable f5vm01ext { default = "10.90.1.4" }
variable f5vm01ext_sec { default = "10.90.1.11" }
variable f5vm02ext { default = "10.90.1.5" }
variable f5vm02ext_sec { default = "10.90.1.12" }
# three_tier bigip external, these must be in the waf_ext subnet
variable f5vm03ext { default = "10.90.6.4" }
variable f5vm03ext_sec { default = "10.90.6.11" }
variable f5vm04ext { default = "10.90.6.5" }
variable f5vm04ext_sec { default = "10.90.6.12" }
# bigip internal private ips, these must be in internal subnet
variable f5vm01int { default = "10.90.2.4" }
variable f5vm01int_sec { default = "10.90.2.11" }
variable f5vm02int { default = "10.90.2.5" }
variable f5vm02int_sec { default = "10.90.2.12" }
# three_tier bigip internal, these must be in waf_int subnet
variable f5vm03int { default = "10.90.7.4" }
variable f5vm04int { default = "10.90.7.5" }

# azure internal load balancer, must be in internal subnet
variable ilb01ip { default = "10.90.2.10" }

# Example application private ips, *currently* must be in internal subnet
variable app01ip { default = "10.90.2.101" }

# Example IPS private ips
variable ips01ext { default = "10.90.4.4" }
variable ips01int { default = "10.90.5.4" }

# winjump, must be in VDMS subnet
variable winjumpip { default = "10.90.3.98" }

# linuxjump, must be in VDMS subnet
variable linuxjumpip { default = "10.90.3.99" }

# BIGIP Instance Type, DS5_v2 is a solid baseline for BEST
variable instanceType { default = "Standard_DS5_v2" }

# Be careful which instance type selected, jump boxes currently use Premium_LRS managed disks
variable jumpinstanceType { default = "Standard_B2s" }

# BIGIP Image
variable image_name {
  type        = string
  description = "REQUIRED: BIG-IP Image Name.  'az vm image list --output table --publisher f5-networks --location [region] --offer f5-big-ip --all'  Default f5-bigip-virtual-edition-1g-best-hourly is PAYG Image.  For BYOL use f5-big-all-2slot-byol"
  default     = "f5-bigip-virtual-edition-1g-best-hourly"
}
variable product {
  type        = string
  description = "REQUIRED: BYOL = f5-big-ip-byol, PAYG = f5-big-ip-best"
  default     = "f5-big-ip-best"
}
variable bigip_version {
  type        = string
  description = "REQUIRED: BIG-IP Version, 14.1.2 for Compliance.  Options: 12.1.502000, 13.1.304000, 14.1.206000, 15.0.104000, latest.  Note: verify available versions before using as images can change."
  default     = "14.1.202000"
}

# BIGIP Setup
# Licenses are only needed when using BYOL images
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
variable host3_name { default = "f5vm03" }
variable host4_name { default = "f5vm04" }
variable dns_server { default = "8.8.8.8,8.8.4.4" }
variable ntp_server { default = "time.nist.gov,0.us.pool.ntp.org" }
variable timezone { default = "UTC" }
variable onboard_log { default = "/var/log/startup-script.log" }

## ASM Policy
variable asm_policy {
  type        = string
  description = "REQUIRED: ASM Policy.  Examples:  https://github.com/f5devcentral/f5-asm-policy-templates.  Default: OWASP Ready Autotuning"
  default     = "https://raw.githubusercontent.com/f5devcentral/f5-asm-policy-templates/master/owasp_ready_template/owasp-auto-tune-v1.1.xml"
}

# TAGS
variable tags {
  description = "Environment tags for objects"
  type        = map(string)
  default = {
    "purpose"     = "public"
    "environment" = "f5env" #ex. dev/staging/prod
    "owner"       = "f5owner"
    "group"       = "f5group"
    "costcenter"  = "f5costcenter"
    "application" = "f5app"
  }
}
