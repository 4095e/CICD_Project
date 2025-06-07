#!/bin/bash

# fix_port_8080.sh - Automatically fixes access to port 8080 on Azure VM

set -e

PORT=8080
RULE_NAME="Allow-Port-${PORT}"
PRIORITY=1001

echo "🔍 Step 1: Checking for Azure CLI and jq..."

if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI (az) is not installed. Please install it first."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "❌ jq is not installed. Installing jq..."
    sudo apt update && sudo apt install -y jq
fi

echo "🧠 Step 2: Fetching instance metadata..."

VM_NAME=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance/compute/name?api-version=2021-02-01&format=text")
RESOURCE_GROUP=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance/compute/resourceGroupName?api-version=2021-02-01&format=text")

echo "💡 VM Name: $VM_NAME"
echo "💡 Resource Group: $RESOURCE_GROUP"

if [[ -z "$VM_NAME" || -z "$RESOURCE_GROUP" ]]; then
    echo "❌ Failed to fetch metadata. Are you running this in Azure?"
    exit 1
fi

echo "🔌 Step 3: Identifying NSG associated with the NIC..."

NIC_ID=$(az vm show -g "$RESOURCE_GROUP" -n "$VM_NAME" --query "networkProfile.networkInterfaces[0].id" -o tsv)
NIC_NAME=$(basename "$NIC_ID")
NSG_ID=$(az network nic show --ids "$NIC_ID" --query "networkSecurityGroup.id" -o tsv)
NSG_NAME=$(basename "$NSG_ID")

if [[ -z "$NSG_NAME" ]]; then
    echo "❌ No NSG associated with this VM's NIC."
    exit 1
fi

echo "✅ Found NSG: $NSG_NAME"

echo "🚪 Step 4: Creating NSG rule to allow TCP on port $PORT..."

az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "$NSG_NAME" \
  --name "$RULE_NAME" \
  --priority $PRIORITY \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --destination-port-range "$PORT" \
  --source-address-prefixes '*' \
  --destination-address-prefixes '*' \
  --description "Allow TCP traffic on port $PORT"

echo "🧪 Step 5: Verifying if service is bound to 0.0.0.0:$PORT..."

if ss -tuln | grep -q ":$PORT "; then
    echo "✅ Your service is listening on port $PORT"
else
    echo "⚠️ Your service is NOT listening on port $PORT. Make sure your Python app binds to 0.0.0.0 instead of 127.0.0.1"
    echo "👉 Try running: python3 -m http.server $PORT --bind 0.0.0.0"
fi

echo "🌐 Step 6: Test from outside: curl http://<VM_Public_IP>:$PORT/metrics"
echo "✅ Done."
