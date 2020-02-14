# templates directory
variable "templates" {
  default = "/workspace/templates"
}


variable "resourceGroup" {
    default= "scca-tf-rg"
}


# bigip network
variable f5vm01mgmt { default = "10.90.1.4" }
variable f5vm01ext { default = "10.90.2.4" }
variable f5vm01ext_sec { default = "10.90.2.11" }
variable f5vm01int { default = "10.90.3.4"}
variable f5vm02mgmt { default = "10.90.1.5" }
variable f5vm02ext { default = "10.90.2.5" }
variable f5vm02ext_sec { default = "10.90.2.12" }
variable f5vm02int { default = "10.90.3.5"}


# BIGIP Image
variable instance_type { default = "Standard_DS4_v2" }
variable image_name { default = "f5-bigip-virtual-edition-25m-best-hourly" }
variable product { default = "f5-big-ip-best" }
variable bigip_version { default = "latest" }

# BIGIP Setup
variable license1 { default = "" }
variable license2 { default = "" }
variable host1_name { default = "f5vm01" }
variable host2_name { default = "f5vm02" }
variable dns_server { default = "8.8.8.8" }
variable ntp_server { default = "0.us.pool.ntp.org" }
variable timezone { default = "UTC" }
variable onboard_log { default = "/var/log/startup-script.log" }