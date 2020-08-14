#!/bin/zsh
cd bin
DATA=$(cat ../increase.json | jq -c '.')
BROKERS=$( echo ${DATA} | jq -r  '.brokers')
DETAILS=$( echo ${DATA} | jq -c  '.details')

if [ -z $BROKERS ] || [ -z $DETAILS ]; then
    echo "missing brokers or related details"
    exit 1
fi
BROKER=$( echo ${BROKERS} | jq -r  '.[0]')
for detail in $(echo $DETAILS | jq -c '.[]'); do
    TOPIC=$( echo ${detail} | jq -r  '.topic')
    PARTITION=$( echo ${detail} | jq -r  '.partition')
    CURRENT_PARTITION_COUNT=$(./kafka-topics --describe --zookeeper localhost:2181 --topic ${TOPIC} | awk '{print $2}' | uniq -c | awk '{print $1}')

    if [ -z $TOPIC ] || [ -z $PARTITION ] ; then
        echo "one or more required params is missing, exiting with code 1"
        exit 1
    fi
    echo "Current Partition count ${CURRENT_PARTITION_COUNT}, new one: ${PARTITION}"
    if ./kafka-topics --list --bootstrap-server $BROKER | grep -q $TOPIC; then
        if [ ${PARTITION} -gt ${CURRENT_PARTITION_COUNT} ]; then
            echo "$TOPIC exists. Updating the partition count to: ${PARTITION}"
            UPDATE_PARTITION_COUNT=$(./kafka-topics --bootstrap-server ${BROKER} --alter --topic ${TOPIC} --partitions ${PARTITION}) 
            echo "$UPDATE_PARTITION_COUNT"
            echo "............................."
        else
            echo "No Change in partition count for ${TOPIC}.Continuing......"
        fi
    else
        echo "The topic ${TOPIC} doesnt exist."
    fi
done