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
az provider register -n "Microsoft.IoTOperations"
az provider register -n "Microsoft.DeviceRegistry"
az provider register -n "Microsoft.SecretSyncController"

echo "create the resource group"
az group create --location $LOCATION --resource-group $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID

echo "connect the cluster"
az connectedk8s connect -n $CLUSTER_NAME -l $LOCATION -g $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID

echo "extract the service principal"
export OBJECT_ID=$(az ad sp show --id bc313c14-388c-4e7d-a58e-70017303ee3b --query id -o tsv)

echo "enable custom locations"
az connectedk8s enable-features -n $CLUSTER_NAME -g $RESOURCE_GROUP --custom-locations-oid $OBJECT_ID --features cluster-connect custom-locations --subscription $SUBSCRIPTION_ID

#echo "verify host - check everything is set up correctly"
#az iot ops verify-host

# Create a storage account and schema registry
## Create a storage account with hierarchical namespace enabled
az storage account create --name $STORAGE_ACCOUNT --location $LOCATION --resource-group $RESOURCE_GROUP --enable-hierarchical-namespace --subscription $SUBSCRIPTION_ID

## Create a schema registry that connects to your storage account
az iot ops schema registry create --name $SCHEMA_REGISTRY --resource-group $RESOURCE_GROUP --registry-namespace $SCHEMA_REGISTRY_NAMESPACE --sa-resource-id $(az storage account show --name $STORAGE_ACCOUNT -o tsv --query id)

# Are we using the Data Processor feature? if so, at this stage we need to install this extension version
if [ "$USE_DP" = true ]; then
    az extension add --upgrade --name azure-iot-ops --version 0.5.1b1
fi

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

az iot ops init --cluster $CLUSTER_NAME --resource-group $RESOURCE_GROUP
az iot ops create --cluster $CLUSTER_NAME --resource-group $RESOURCE_GROUP --name ${CLUSTER_NAME}-instance  --sr-resource-id $(az iot ops schema registry show --name $SCHEMA_REGISTRY --resource-group $RESOURCE_GROUP -o tsv --query id) --broker-frontend-replicas 1 --broker-frontend-workers 1  --broker-backend-part 1  --broker-backend-workers 1 --broker-backend-rf 2 --broker-mem-profile Low


kubectl get pods -n azure-iot-operations

# TODO 
# Look into creation using sp-id https://learn.microsoft.com/en-us/cli/azure/iot/ops?view=azure-cli-latest#az-iot-ops-init