#!/bin/zsh
cd bin
./kafka-reassign-partitions --bootstrap-server localhost:9092 --reassignment-json-file ../update_replication_factor.json  --execute --zookeeper localhost:2181

