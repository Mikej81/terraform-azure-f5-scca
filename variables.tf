# Azure Environment
variable projectPrefix { default = "scca" }
variable adminUserName { default = "xadmin" }
variable adminPassword { default = "2018F5Networks!!" }
variable location { default = "usgovvirginia" }
variable region { default = "USGov Virginia" }
# one_tier or three_tier
variable deploymentType { default = "one_tier" }
variable sshPublicKey {
  type        = string
  description = "ssh public key for instances"
  default     = ""
}
variable sshPublicKeyPath { default = "/mykey.pub" }

# NETWORK
variable cidr { default = "10.90.0.0/16" }
variable subnets {
  type = map(string)
  default = {
    "management"  = "10.90.1.0/24"
    "external"    = "10.90.2.0/24"
    "internal"    = "10.90.3.0/24"
    "inspect_ext" = "10.90.4.0/24"
    "inspect_int" = "10.90.5.0/24"
    "waf_ext"     = "10.90.6.0/24"
    "waf_int"     = "10.90.7.0/24"
  }
}
# bigip mgmt private ips
variable f5vm01mgmt { default = "10.90.1.4" }
variable f5vm02mgmt { default = "10.90.1.5" }
variable f5vm03mgmt { default = "10.90.1.6" }
variable f5vm04mgmt { default = "10.90.1.7" }

# bigip external private ips
variable f5vm01ext { default = "10.90.2.4" }
variable f5vm01ext_sec { default = "10.90.2.11" }
variable f5vm02ext { default = "10.90.2.5" }
variable f5vm02ext_sec { default = "10.90.2.12" }
variable f5vm03ext { default = "10.90.6.4" }
variable f5vm03ext_sec { default = "10.90.6.11" }
variable f5vm04ext { default = "10.90.6.5" }
variable f5vm04ext_sec { default = "10.90.6.12" }
# bigip internal private ips
variable f5vm01int { default = "10.90.3.4" }
variable f5vm02int { default = "10.90.3.5" }
variable f5vm03int { default = "10.90.7.4" }
variable f5vm04int { default = "10.90.7.5" }
# Example application private ips
variable app01ip { default = "10.90.2.101" }



# winjump
variable winjumpip { default = "10.90.2.98" }

# linuxjump
variable linuxjumpip { default = "10.90.2.99" }

# device
variable instanceType { default = "Standard_DS5_v2" }

# Be careful which instance type selected, jump boxes currently use Premium_LRS managed disks
variable jumpinstanceType { default = "Standard_B2s" }

# BIGIP Image
# check available image names with az cli:
#    az vm image list --output table --publisher f5-networks --location usgovvirginia --offer f5-big-ip --all
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
variable license3 { default = "" }
variable license4 { default = "" }
variable host1_name { default = "f5vm01" }
variable host2_name { default = "f5vm02" }
variable host3_name { default = "f5vm03" }
variable host4_name { default = "f5vm04" }
variable dns_server { default = "8.8.8.8,8.8.4.4" }
variable ntp_server { default = "time.nist.gov,0.us.pool.ntp.org" }
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
