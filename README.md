# Deploying BIG-IP VEs in Azure - ConfigSync Cluster (Active/Standby): Two NICs

## Contents

- [Deploying BIG-IP VEs in Azure - ConfigSync Cluster (Active/Standby): Two NICs](#deploying-big-ip-ves-in-azure---configsync-cluster-activestandby-two-nics)
  - [Contents](#contents)
  - [Introduction](#introduction)
  - [Prerequisites](#prerequisites)
  - [Important configuration notes](#important-configuration-notes)
  - [docker](#docker)
    - [requirements](#requirements)

## Introduction

This solution uses an Terraform template to launch a three NIC deployment of a cloud-focused BIG-IP VE cluster (Active/Standby) in Microsoft Azure. Traffic flows from an ALB to the BIG-IP VE which then processes the traffic to application servers. This is the standard cloud design where the BIG-IP VE instance is running with a dual interface, where both management and data plane traffic is processed on each one.

The BIG-IP VEs have the following features / modules enabled:

- [Local / Global Availability](https://f5.com/products/big-ip/local-traffic-manager-ltm)

- [Firewall](https://www.f5.com/products/security/advanced-firewall-manager)
  - Firewall with Intrusion Protection and IP Intelligence only available with BYOL deployments today.

- [Web Application Firewall](https://www.f5.com/products/security/advanced-waf)

## Prerequisites

- **Important**: When you configure the admin password for the BIG-IP VE in the template, you cannot use the character **#**.  Additionally, there are a number of other special characters that you should avoid using for F5 product user accounts.  See [K2873](https://support.f5.com/csp/article/K2873) for details.
- This template requires a service principal, one will be created in the setupAzureVars.sh.  See the [Service Principal Setup section](#service-principal-authentication) for details, including required permissions.
- This deployment will be using the Terraform Azurerm provider to build out all the neccessary Azure objects. Therefore, Azure CLI is required. for installation, please follow this [Microsoft link](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest)
- If this is the first time to deploy the F5 image, the subscription used in this deployment needs to be enabled to programatically deploy. For more information, please refer to [Configure Programatic Deployment](https://azure.microsoft.com/en-us/blog/working-with-marketplace-images-on-azure-resource-manager/)
- You need to set your region and log in to azure ahead of time, the scripts will map your authenitcation credentials and create a service principle, so you will not need to hardcode any credentials in the files.

## Important configuration notes

- All variables are configured in variables.tf

## variables

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.13 |
| azurerm | ~> 2.15.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 2.15.0 |

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| projectPrefix | REQUIRED: Prefix to prepend to all objects created, minus Windows Jumpbox | `string` | `"mjcscca"` |
| adminUserName | REQUIRED: Admin Username for All systems | `string` | `"xadmin"` |
| adminPassword | REQUIRED: Admin Password for all systems | `string` | `"pleaseUseVault123!!"` |
| location | REQUIRED: Azure Region: usgovvirginia, usgovarizona, etc | `string` | `"usgovvirginia"` |
| region | Azure Region: US Gov Virginia, US Gov Arizona, etc | `string` | `"USGov Virginia"` |
| deploymentType | REQUIRED: This determines the type of deployment; one tier versus three tier: one\_tier, three\_tier | `string` | `"one_tier"` |
| deployDemoApp | OPTIONAL: Deploy Demo Application with Stack. Recommended to show functionality.  Options: deploy, anything else. | `string` | `"deploy"` |
| sshPublicKey | OPTIONAL: ssh public key for instances | `string` | `""` |
| sshPublicKeyPath | OPTIONAL: ssh public key path for instances | `string` | `"/mykey.pub"` |
| cidr | REQUIRED: VNET Network CIDR | `string` | `"10.90.0.0/16"` |
| subnets | REQUIRED: Subnet CIDRs | `map(string)` | <pre>{<br>  "application": "10.90.10.0/24",<br>  "external": "10.90.1.0/24",<br>  "inspect_ext": "10.90.4.0/24",<br>  "inspect_int": "10.90.5.0/24",<br>  "internal": "10.90.2.0/24",<br>  "management": "10.90.0.0/24",<br>  "vdms": "10.90.3.0/24",<br>  "waf_ext": "10.90.6.0/24",<br>  "waf_int": "10.90.7.0/24"<br>}</pre> |
| f5\_mgmt | F5 BIG-IP Management IPs.  These must be in the management subnet. | `map(string)` | <pre>{<br>  "f5vm01mgmt": "10.90.0.4",<br>  "f5vm02mgmt": "10.90.0.5",<br>  "f5vm03mgmt": "10.90.0.6",<br>  "f5vm04mgmt": "10.90.0.7"<br>}</pre> |
| f5\_t1\_ext | Tier 1 BIG-IP External IPs.  These must be in the external subnet. | `map(string)` | <pre>{<br>  "f5vm01ext": "10.90.1.4",<br>  "f5vm01ext_sec": "10.90.1.11",<br>  "f5vm02ext": "10.90.1.5",<br>  "f5vm02ext_sec": "10.90.1.12"<br>}</pre> |
| f5\_t1\_int | Tier 1 BIG-IP Internal IPs.  These must be in the internal subnet. | `map(string)` | <pre>{<br>  "f5vm01int": "10.90.2.4",<br>  "f5vm01int_sec": "10.90.2.11",<br>  "f5vm02int": "10.90.2.5",<br>  "f5vm02int_sec": "10.90.2.12"<br>}</pre> |
| f5\_t3\_ext | Tier 3 BIG-IP External IPs.  These must be in the waf external subnet. | `map(string)` | <pre>{<br>  "f5vm03ext": "10.90.6.4",<br>  "f5vm03ext_sec": "10.90.6.11",<br>  "f5vm04ext": "10.90.6.5",<br>  "f5vm04ext_sec": "10.90.6.12"<br>}</pre> |
| f5\_t3\_int | Tier 3 BIG-IP Internal IPs.  These must be in the waf internal subnet. | `map(string)` | <pre>{<br>  "f5vm03int": "10.90.7.4",<br>  "f5vm03int_sec": "10.90.7.11",<br>  "f5vm04int": "10.90.7.5",<br>  "f5vm04int_sec": "10.90.7.12"<br>}</pre> |
| ilb01ip | azure internal load balancer, must be in internal subnet | `string` | `"10.90.2.10"` |
| app01ip | Example application private ips, *currently* must be in internal subnet | `string` | `"10.90.10.101"` |
| ips01ext | Example IPS private ips | `string` | `"10.90.4.4"` |
| ips01int | n/a | `string` | `"10.90.5.4"` |
| winjumpip | winjump, must be in VDMS subnet | `string` | `"10.90.3.98"` |
| linuxjumpip | linuxjump, must be in VDMS subnet | `string` | `"10.90.3.99"` |
| instanceType | BIGIP Instance Type, DS5\_v2 is a solid baseline for BEST | `string` | `"Standard_DS5_v2"` |
| jumpinstanceType | Be careful which instance type selected, jump boxes currently use Premium\_LRS managed disks | `string` | `"Standard_B2s"` |
| image\_name | REQUIRED: BIG-IP Image Name.  'az vm image list --output table --publisher f5-networks --location [region] --offer f5-big-ip --all'  Default f5-bigip-virtual-edition-1g-best-hourly is PAYG Image.  For BYOL use f5-big-all-2slot-byol | `string` | `"f5-bigip-virtual-edition-1g-best-hourly"` |
| product | REQUIRED: BYOL = f5-big-ip-byol, PAYG = f5-big-ip-best | `string` | `"f5-big-ip-best"` |
| bigip\_version | REQUIRED: BIG-IP Version, 14.1.2 for Compliance.  Options: 12.1.502000, 13.1.304000, 14.1.206000, 15.0.104000, latest.  Note: verify available versions before using as images can change. | `string` | `"14.1.202000"` |
| licenses | BIGIP Setup Licenses are only needed when using BYOL images | `map(string)` | <pre>{<br>  "license1": "",<br>  "license2": "",<br>  "license3": "",<br>  "license4": ""<br>}</pre> |
| hosts | n/a | `map(string)` | <pre>{<br>  "host1": "f5vm01",<br>  "host2": "f5vm02",<br>  "host3": "f5vm03",<br>  "host4": "f5vm04"<br>}</pre> |
| dns\_server | n/a | `string` | `"8.8.8.8"` |
| ntp\_server | n/a | `string` | `"time.nist.gov"` |
| timezone | n/a | `string` | `"UTC"` |
| onboard\_log | n/a | `string` | `"/var/log/startup-script.log"` |
| asm\_policy | REQUIRED: ASM Policy.  Examples:  https://github.com/f5devcentral/f5-asm-policy-templates.  Default: OWASP Ready Autotuning | `string` | `"https://raw.githubusercontent.com/f5devcentral/f5-asm-policy-templates/master/owasp_ready_template/owasp-auto-tune-v1.1.xml"` |
| tags | Environment tags for objects | `map(string)` | <pre>{<br>  "application": "f5app",<br>  "costcenter": "f5costcenter",<br>  "environment": "f5env",<br>  "group": "f5group",<br>  "owner": "f5owner",<br>  "purpose": "public"<br>}</pre> |

## Outputs

| Name | Description |
|------|-------------|
| sg\_id | Network Security Group ID |
| sg\_name | Network Security Group Name |
| ALB\_app1\_pip | Public IP for applications.  Https for example app, RDP for Windows Jumpbox, SSH for Linux Jumpbox |
| tier\_one | One Tier Outputs:  VM IDs, VM Mgmt IPs, VM External Private IPs |
| tier\_three | Three Tier Outputs:  VM IDs, VM Mgmt IPs, VM External Private IPs |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Deployment

For deployment you can do the traditional terraform commands or use the provided scripts.

```bash
terraform init
terraform plan
terraform apply
```

```bash
./demo.sh
```

## Destruction

For destruction / tear down you can do the trafitional terraform commands or use the provided scripts.

```bash
terraform destroy
```

```bash
./cleanup.sh
```

## Development

Outline any requirements to setup a development environment if someone would like to contribute.  You may also link to another file for this information.

  ```bash
  # test pre commit manually
  pre-commit run -a -v
  ```
