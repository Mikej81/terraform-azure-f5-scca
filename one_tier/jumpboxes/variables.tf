# Instance Type

variable instanceType {}

# winjump
variable winjumpip { }

# linuxjump
variable linuxjumpip { }

variable timezone { default = "UTC" }

# cloud
variable region { default = "none" }
variable prefix {  }
variable resourceGroup { }
variable securityGroup { default = "none" }

# network
variable subnetExternal { default = "none"}

# creds
variable adminUserName { default = "admin" }
variable adminPassword { default = "2017F5Networks!!" }
variable sshPublicKey { default = "/mykey.pub" }

# TAGS
variable purpose { default = "public" }
variable environment { default = "f5env" } #ex. dev/staging/prod
variable owner { default = "f5owner" }
variable group { default = "f5group" }
variable costcenter { default = "f5costcenter" }
variable application { default = "f5app" }