# Azure Environment
variable projectPrefix { default = "scca" }
variable adminUserName { default = "xadmin" }
variable adminPassword { default = "2018F5Networks!!" }
variable location { default = "usgovvirginia" }
variable region { default = "USGov Virginia" }
variable deploymentType { default = "three_tier" }
variable sshPublicKeyPath { default = "/mykey.pub"}

# NETWORK
variable cidr { default = "10.90.0.0/16" }
variable subnets {
  type = map(string)
  default = {
    "management" = "10.90.1.0/24"
    "external" = "10.90.2.0/24"
    "internal" = "10.90.3.0/24"
  }
}

# bigip mgmt private ips
variable f5vm01mgmt { default = "10.90.1.4" }
variable f5vm02mgmt { default = "10.90.1.5" }

# bigip external private ips
variable f5vm01ext { default = "10.90.2.4" }
variable f5vm01ext_sec { default = "10.90.2.11" }
variable f5vm02ext { default = "10.90.2.5" }
variable f5vm02ext_sec { default = "10.90.2.12" }

# Example application private ips
variable app01ext { default = "10.90.2.101" }

# bigip internal private ips 
variable f5vm01int { default = "10.90.3.4" }
variable f5vm02int { default = "10.90.3.5" }

# winjump
variable winjumpip { default = "10.90.2.98" }

# linuxjump
variable linuxjumpip { default = "10.90.2.99" }

# device
variable instanceType { default = "Standard_DS5_v2" }

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
    license1 = ""
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

# TAGS
variable purpose { default = "public" }
variable environment { default = "f5env" } #ex. dev/staging/prod
variable owner { default = "f5owner" }
variable group { default = "f5group" }
variable costcenter { default = "f5costcenter" }
variable application { default = "f5app" }