# Instance Type

variable instanceType {}

# winjump
variable winjumpip { default = "10.90.2.98" }

# linuxjump
variable linuxjumpip { default = "10.90.2.99" }

variable timezone { default = "UTC" }

# cloud
variable location {}
variable region {}
variable prefix { default = "scca" }
variable subnets {}
variable resourceGroup { default = "scca-tf-rg" }
variable securityGroup { default = "none" }

# network
variable subnetExternal { default = "none" }

# creds
variable adminUserName { default = "admin" }
variable adminPassword { default = "2017F5Networks!!" }
variable sshPublicKey { default = "/mykey.pub" }

# TAGS
variable tags {}
