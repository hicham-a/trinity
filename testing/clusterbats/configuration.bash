CONFIG=/trinity/testing/clusterbats/$(</trinity/site).cfg
source ${CONFIG}
CONTAINERS=${NODES/node/c}
ALL_NODES=$(lsdef $NODES | grep "Object name" | awk -F': ' '{print $2}')
ALL_CONTAINERS=$(lsdef $CONTAINERS | grep "Object name" | awk -F': ' '{print $2}')

