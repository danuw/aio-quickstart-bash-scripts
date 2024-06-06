# Make sure to first run `az login --use-device-code` in the right browser to sign in to your Azure Account
# To ensure your user can access the AIO UI, make sure to specify you iot ops user email with `export USER_EMAIL=<your-email>` - remember that user needs to be a member of the tenat

if [ -z "$SUBSCRIPTION_ID" ]; then
    echo "SUBSCRIPTION_ID is not set - make sure to edit the values in `1-envs.sh` and run it login in with `0-azlogin.sh`"
    exit 1
fi

# you may also want to check that your $RESOURCE_GROUP variable is set correctly override with `export RESOURCE_GROUP=aio-codespace-rg`
echo "set the azure subscription"
az account set -s $SUBSCRIPTION_ID

az config set extension.use_dynamic_install=yes_without_prompt

echo "install azure providers"
az provider register -n "Microsoft.ExtendedLocation"
az provider register -n "Microsoft.Kubernetes"
az provider register -n "Microsoft.KubernetesConfiguration"
az provider register -n "Microsoft.IoTOperationsOrchestrator"
az provider register -n "Microsoft.IoTOperationsMQ"
az provider register -n "Microsoft.IoTOperationsDataProcessor"
az provider register -n "Microsoft.DeviceRegistry"

echo "create the resource group"
az group create --location $LOCATION --resource-group $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID

echo "connect the cluster"
az connectedk8s connect -n $CLUSTER_NAME -l $LOCATION -g $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID

echo "extract the service principal"
export OBJECT_ID=$(az ad sp show --id bc313c14-388c-4e7d-a58e-70017303ee3b --query id -o tsv)

echo "enable custom locations"
az connectedk8s enable-features -n $CLUSTER_NAME -g $RESOURCE_GROUP --custom-locations-oid $OBJECT_ID --features cluster-connect custom-locations

echo "verify host - check everything is set up correctly"
az iot ops verify-host

#az connectedk8s show -n $CLUSTER_NAME -g $RESOURCE_GROUP  --query id -o tsv

echo "Current custom locations:"
az customlocation list -g $RESOURCE_GROUP --query "[].{Name:name, ID:id}"

# Make sure to specify you iot ops user email with `export USER_EMAIL=<your-email>`

echo "Create the keyvault"
az keyvault create --enable-rbac-authorization false --name ${CLUSTER_NAME:0:24} --resource-group $RESOURCE_GROUP

echo "Get the keyvault name into an environment variable"
export KEYVAULT_NAME=$(az keyvault list --resource-group $RESOURCE_GROUP --query "[0].name" -o tsv)

echo "Ensuring '$USER_EMAIL' has access to the iotoperations.azure.com UI"
export userObjectId=$(az ad user show --id $USER_EMAIL --query id -o tsv)
az role assignment create --role Contributor --assignee-object-id $userObjectId --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP

echo "Initialize the IoT Operations instance"
az iot ops init --simulate-plc --cluster $CLUSTER_NAME --resource-group $RESOURCE_GROUP --kv-id $(az keyvault show --name ${CLUSTER_NAME:0:24} -o tsv --query id)

kubectl get pods -n azure-iot-operations

# TODO 
# Look into creation using sp-id https://learn.microsoft.com/en-us/cli/azure/iot/ops?view=azure-cli-latest#az-iot-ops-init