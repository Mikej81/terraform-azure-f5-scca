#!/bin/bash
# install tools for container standup
echo "cwd: $(pwd)"
echo "---getting tools---"
sudo apt-get update
sudo apt-get install -y jq less
# tools
. .devcontainer/scripts/azurecli.sh
. .devcontainer/scripts/terraform.sh
. .devcontainer/scripts/terraformDocs.sh
. .devcontainer/scripts/preCommit.sh
echo "---tools done---"
