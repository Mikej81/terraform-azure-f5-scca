
variable prefix {
  default ="scca"
}
variable resourceGroup {
    default= "scca-tf-rg"
}
variable securityGroup {
  default = "none"
}

variable subnetExternal {
  default= "none"
}

variable app01ext { default = "10.90.2.101" }
variable adminUserName { default = "admin" }
variable adminPassword { default = "2017F5Networks!!" }

# TAGS
variable purpose { default = "public" }
variable environment { default = "f5env" } #ex. dev/staging/prod
variable owner { default = "f5owner" }
variable group { default = "f5group" }
variable costcenter { default = "f5costcenter" }
variable application { default = "f5app" }