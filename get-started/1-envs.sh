# /!\ Make sure to edit the values below to match your environment. Codespace should already have most settings, but they are available in case you wanted to override easily

echo "Setting up environment variables"

export UNIQUE_ID=your-unique-identifier-here
#export SUBSCRIPTION_ID=...
#export LOCATION="westeurope" # use one of the available regions. Use of these supported regions in public preview: eastus, eastus2, westus, westus2, westus3, westeurope, or northeurope.
#export RESOURCE_GROUP=we-aio-rg-$UNIQUE_ID
#export CLUSTER_NAME=we-aio-arck-$UNIQUE_ID # https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations#compute-and-web
#export KEYVAULT_NAME=we-aio-kv-$UNIQUE_ID
export USER_EMAIL=<username@TENANTNAME.onmicrosoft.com> # set here - if you have not created, consider using those steps https://learn.microsoft.com/en-us/cli/azure/ad/user?view=azure-cli-latest#az-ad-user-create

echo "Environment variables set to create '$CLUSTER_NAME' in '$LOCATION' under '$RESOURCE_GROUP'"