#!/bin/bash

# Variables (update if needed)
RESOURCE_GROUP="vm-rg"
VM_NAME="demo-vm"
NIC_NAME="demo-vm-nic"
NSG_NAME="demo-vm-nsg"
VNET_NAME="vm-vnet"
SUBNET_NAME="vm-subnet"

echo "1. Checking NSG attached to NIC..."
NIC_NSG_ID=$(az network nic show --resource-group $RESOURCE_GROUP --name $NIC_NAME --query "networkSecurityGroup.id" -o tsv)
echo "NIC NSG ID: $NIC_NSG_ID"

echo "2. Listing NSG rules for $NSG_NAME..."
az network nsg rule list --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME --query "[].{Name:name,Priority:priority,Direction:direction,Access:access,Protocol:protocol,Port:destinationPortRange}" -o table

echo "3. Checking subnet NSG..."
SUBNET_NSG_ID=$(az network vnet subnet show --resource-group $RESOURCE_GROUP --vnet-name $VNET_NAME --name $SUBNET_NAME --query "networkSecurityGroup.id" -o tsv)

if [[ "$SUBNET_NSG_ID" != "null" && -n "$SUBNET_NSG_ID" ]]; then
  SUBNET_NSG_NAME=$(basename $SUBNET_NSG_ID)
  echo "Subnet NSG: $SUBNET_NSG_NAME"
  echo "Listing subnet NSG rules..."
  az network nsg rule list --resource-group $RESOURCE_GROUP --nsg-name $SUBNET_NSG_NAME --query "[].{Name:name,Priority:priority,Direction:direction,Access:access,Protocol:protocol,Port:destinationPortRange}" -o table
else
  echo "No NSG associated with subnet $SUBNET_NAME."
fi

echo "4. Checking if NSG rule Allow-Grafana-3000 exists..."
RULE_EXISTS=$(az network nsg rule show --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME --name Allow-Grafana-3000 --query "name" -o tsv 2>/dev/null || echo "")
if [[ "$RULE_EXISTS" == "Allow-Grafana-3000" ]]; then
  echo "NSG rule Allow-Grafana-3000 already exists."
else
  echo "Adding NSG rule Allow-Grafana-3000..."
  az network nsg rule create --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME --name Allow-Grafana-3000 \
    --priority 300 --direction Inbound --access Allow --protocol Tcp --destination-port-ranges 3000
fi

echo "5. Getting VM Public IP..."
PUBLIC_IP=$(az vm list-ip-addresses --resource-group $RESOURCE_GROUP --name $VM_NAME --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv)
echo "Public IP of VM is: $PUBLIC_IP"

echo "6. Please SSH into the VM ($VM_NAME) and run the following commands:"
echo "  sudo ss -tulnp | grep 3000"
echo "  sudo ufw status verbose"
echo "  If UFW is active, run: sudo ufw allow 3000/tcp && sudo ufw reload"
echo "  sudo systemctl restart grafana-server"

echo "7. From your local machine, test connectivity to Grafana port 3000:"
echo "  nc -vz $PUBLIC_IP 3000"
echo "  curl -I http://$PUBLIC_IP:3000"

echo "Script completed."
