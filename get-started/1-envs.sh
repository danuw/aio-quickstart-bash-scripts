# /!\ Make sure to edit the values below to match your environment. Codespace should already have most settings, but they are available in case you wanted to override easily

echo "Setting up environment variables"

export UNIQUE_ID=<your-unique-identifier-here>
export SUBSCRIPTION_ID=export SUBSCRIPTION_ID=$(az account show --query id --output tsv) ## use this if you tend to use the same GitHub account across multiple azure subscription to ensure it is aligned with the currently logged in user's subscriptions
export LOCATION="westeurope" # use one of the available regions. Use of these supported regions in public preview: eastus, eastus2, westus, westus2, westus3, westeurope, or northeurope.
export RESOURCE_GROUP=we-aio-rg-$UNIQUE_ID
export CLUSTER_NAME=we-aio-arck-$UNIQUE_ID # https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations#compute-and-web
export KEYVAULT_NAME=we-aio-kv-$UNIQUE_ID
export KV_NAME=we-aio-kv-$UNIQUE_ID
export INSTANCE_NAME=we-aio-ins-$UNIQUE_ID
export USER_EMAIL=<username@TENANTNAME.onmicrosoft.com> # set here - if you have not created, consider using those steps https://learn.microsoft.com/en-us/cli/azure/ad/user?view=azure-cli-latest#az-ad-user-create


# add a check that the USER EMAIL does not contain the < symbol
if [[ $USER_EMAIL == *"<"* ]]; then
    echo "!!! USER_EMAIL contains the < symbol. Please remove the < symbol from the USER_EMAIL environment variable."
    exit 1
fi

echo "Environment variables set to create '$CLUSTER_NAME' in '$LOCATION' under '$RESOURCE_GROUP'."
echo "'$USER_EMAIL' will be provided contributor access to this resource group."
