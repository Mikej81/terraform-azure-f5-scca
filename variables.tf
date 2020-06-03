# Azure Environment
variable projectPrefix { default = "scca" }
variable adminUserName { default = "xadmin" }
variable adminPassword { default = "2018F5Networks!!" }
variable location { default = "usgovvirginia" }
variable region { default = "USGov Virginia" }
variable "deploymentType" { default = "single_tier" }
variable sshPublicKeyPath { default = "/mykey.pub"}

# NETWORK
variable cidr { default = "10.90.0.0/16" }
variable "subnets" {
  type = map(string)
  default = {
    "subnet1" = "10.90.1.0/24"
    "subnet2" = "10.90.2.0/24"
    "subnet3" = "10.90.3.0/24"
  }
}

# TAGS
variable purpose { default = "public" }
variable environment { default = "f5env" } #ex. dev/staging/prod
variable owner { default = "f5owner" }
variable group { default = "f5group" }
variable costcenter { default = "f5costcenter" }
variable application { default = "f5app" }