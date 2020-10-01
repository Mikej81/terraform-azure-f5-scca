
variable prefix { }
variable resourceGroup { }
variable securityGroup {
  default = "none"
}

variable subnetExternal {
  default = "none"
}

variable app01ext { }
variable adminUserName { }
variable adminPassword { }

# TAGS
variable purpose { default = "public" }
variable environment { default = "f5env" } #ex. dev/staging/prod
variable owner { default = "f5owner" }
variable group { default = "f5group" }
variable costcenter { default = "f5costcenter" }
variable application { default = "f5app" }