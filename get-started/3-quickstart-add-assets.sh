
if [ -z "$SUBSCRIPTION_ID" ]; then
    echo "SUBSCRIPTION_ID is not set - Make sure to rerun `1-envs.sh` to ensure environment variables are set. Then start by running `0-azlogin.sh` to login and then `1-envs.sh`."
    exit 1
fi

# Define the variable
CONNECTOR_NAME="opc-ua-connector-0"
CONNECTOR_URL="opc.tcp://opcplc-000000:50000"
NUM_THERMOSTATS=3

# Example usage in the script
echo "Using connector: $CONNECTOR_NAME at $CONNECTOR_URL and adding $NUM_THERMOSTATS thermostats"

echo ""
echo "#### Set up OPC UA ####"

echo "Create an asset endpoint"
az iot ops asset endpoint create --name $CONNECTOR_NAME --target-address $CONNECTOR_URL -g $RESOURCE_GROUP --cluster $CLUSTER_NAME

echo ""
kubectl get assetendpointprofile -n azure-iot-operations

echo ""
echo "Configure the simulator /!\ DO NOT USE IN PRODUCTION /!\ "
kubectl patch AssetEndpointProfile $CONNECTOR_NAME -n azure-iot-operations --type=merge -p '{"spec":{"additionalConfiguration":"{\"applicationName\":\"$CONNECTOR_NAME\",\"security\":{\"autoAcceptUntrustedServerCertificates\":true}}"}}'

echo "Adding assets with tags and events"
#az iot ops asset create --name thermostat -g $RESOURCE_GROUP --cluster $CLUSTER_NAME --endpoint $CONNECTOR_NAME --description 'A simulated thermostat asset' --data  data_source='ns=3;s=FastUInt10', name=temperature --data data_source='ns=3;s=FastUInt100', name='Tag 10'

# Loop to create multiple assets
for i in $(seq 1 $NUM_THERMOSTATS); do
    ASSET_NAME="thermostat$i"
    echo "Adding asset: $ASSET_NAME"
    az iot ops asset create --name $ASSET_NAME -g $RESOURCE_GROUP --cluster $CLUSTER_NAME --endpoint $CONNECTOR_NAME --description "A simulated thermostat asset $i" --data data_source='ns=3;s=FastUInt10', name=temperature --data data_source='ns=3;s=FastUInt100', name='Tag 10'
done

echo ""
kubectl get pods -n azure-iot-operations

# Verifying the data is flowing
kubectl apply -f https://raw.githubusercontent.com/Azure-Samples/explore-iot-operations/main/samples/quickstarts/mqtt-client.yaml

kubectl exec --stdin --tty mqtt-client -n azure-iot-operations -- sh

mosquitto_sub --host aio-mq-dmqtt-frontend --port 8883 --topic "azure-iot-operations/data/#" -v --debug --cafile /var/run/certs/ca.crt -D CONNECT authentication-method 'K8S-SAT' -D CONNECT authentication-data $(cat /var/run/secrets/tokens/mq-sat)