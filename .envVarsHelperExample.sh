#!/bin/bash
## set vars
# azure
arm_resource_group=""
arm_client_id=""
arm_client_secret=""
arm_subscription_id=""
arm_tenant_id=""
# creds
# ssh_key_dir="$(echo $HOME)/.ssh"
# ssh_key_name="id_rsa"
ssh_key_dir=""
ssh_key_name=""
azure_ssh_key_name=""
azure_pub_key_name=""
# azure
export ARM_RESOURCE_GROUP=${arm_resource_group}
export ARM_SUBSCRIPTION_ID=${arm_subscription_id}
export ARM_TENANT_ID=${arm_tenant_id}
export ARM_CLIENT_ID=${arm_client_id}
export ARM_CLIENT_SECRET=${arm_client_secret}
export AZURE_SSH_KEY_NAME=${azure_ssh_key_name}
export AZURE_PUB_KEY_NAME=${azure_pub_key_name}
# creds
export SSH_KEY_DIR=${ssh_key_dir}
export SSH_KEY_NAME=${ssh_key_name}

echo "env vars done"