# Instance Type

variable instanceType {}

# winjump
variable winjumpip {}

# linuxjump
variable linuxjumpip {}

variable timezone { default = "UTC" }

# cloud
variable region { default = "none" }
variable prefix {}
variable resourceGroup {}
variable securityGroup { default = "none" }

# network
variable subnet { default = "none" }

# creds
variable adminUserName { default = "" }
variable adminPassword { default = "" }
variable sshPublicKey { default = "" }

# TAGS
variable purpose { default = "public" }
variable environment { default = "f5env" } #ex. dev/staging/prod
variable owner { default = "f5owner" }
variable group { default = "f5group" }
variable costcenter { default = "f5costcenter" }
variable application { default = "f5app" }
