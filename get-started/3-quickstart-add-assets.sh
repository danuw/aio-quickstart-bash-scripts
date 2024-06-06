
if [ -z "$SUBSCRIPTION_ID" ]; then
    echo "SUBSCRIPTION_ID is not set - Make sure to rerun `1-envs.sh` to ensure environment variables are set. Then start by running `0-azlogin.sh` to login and then `1-envs.sh`."
    exit 1
fi

echo ""
echo "#### Set up OPC UA ####"

echo "Create an asset endpoint"
az iot ops asset endpoint create --name opc-ua-connector-0 --target-address opc.tcp://opcplc-000000:50000 -g $RESOURCE_GROUP --cluster $CLUSTER_NAME

kubectl get assetendpointprofile -n azure-iot-operations

echo "Configure the simulator /!\ DO NOT USE IN PRODUCTION /!\ "
kubectl patch AssetEndpointProfile opc-ua-connector-0 -n azure-iot-operations --type=merge -p '{"spec":{"additionalConfiguration":"{\"applicationName\":\"opc-ua-connector-0\",\"security\":{\"autoAcceptUntrustedServerCertificates\":true}}"}}'

echo "Add an asset, tags, and events"
az iot ops asset create --name thermostat -g $RESOURCE_GROUP --cluster $CLUSTER_NAME --endpoint opc-ua-connector-0 --description 'A simulated thermostat asset' --data  data_source='ns=3;s=FastUInt10', name=temperature --data data_source='ns=3;s=FastUInt100', name='Tag 10'

kubectl get pods -n azure-iot-operations
