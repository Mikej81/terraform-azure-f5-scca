# Azure Environment
variable projectPrefix { default = "scca" }
variable adminUserName { default = "xadmin" }
variable adminPassword { default = "2018F5Networks!!" }
variable location { default = "usgovvirginia" }
variable region { default = "USGov Virginia" }
variable deploymentType { default = "single_tier" }
variable sshPublicKeyPath { default = "/mykey.pub"}

# device
variable instanceType { default = "Standard_DS5_v2" }

# NETWORK
variable cidr { default = "10.90.0.0/16" }
variable subnets {
  type = map(string)
  default = {
    "subnet1" = "10.90.1.0/24"
    "subnet2" = "10.90.2.0/24"
    "subnet3" = "10.90.3.0/24"
  }
}

# BIGIP Image
variable instanceType { default = "Standard_DS5_v2" }
variable image_name { default = "f5-bigip-virtual-edition-25m-best-hourly" }
variable product { default = "f5-big-ip-best" }
variable bigip_version { default = "latest" }

# BIGIP Setup
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