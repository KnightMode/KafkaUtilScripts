#!/bin/zsh
cd bin
DATA=$(cat ../kafka_details.json | jq -c '.')
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
    REPLICATION_FACTOR=$( echo ${detail} | jq -r  '.replication_factor')
    RETENTION_PERIOD=$( echo ${detail} | jq -r  '.retention_period')

    if [ -z $TOPIC ] || [ -z $PARTITION ] || [ -z $REPLICATION_FACTOR ] || [ -z $RETENTION_PERIOD ] ; then
        echo "one or more required params is missing, exiting with code 1"
        exit 1
    fi

    if ./kafka-topics --list --bootstrap-server $BROKER | grep -q $TOPIC; then
        echo "$TOPIC exists. continuing..."
    else 
        echo "Creating topic: ${TOPIC}..."
        CREATE_TOPIC=$(./kafka-topics --bootstrap-server $BROKER --create --topic $TOPIC  --partitions $PARTITION --replication-factor $REPLICATION_FACTOR --config retention.ms=$RETENTION_PERIOD) 
        echo "$CREATE_TOPIC"
        echo "............................."
    fi
done
