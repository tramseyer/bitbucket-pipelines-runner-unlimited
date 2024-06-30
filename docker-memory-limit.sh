#!/bin/bash
MEMORY=$((1024 * 1024 * 1024 * 1024)) # 1TB
while true
do
    OUTPUT=$(docker inspect --format="{{.Id}} {{.Name}} {{.HostConfig.Memory}} {{.HostConfig.MemorySwap}}" $(docker ps -aq) | grep ".*_build" | grep -v "_build\s$MEMORY")
    if [ $? -eq 0 ]; then
        echo "Found *_build container with different memory limit: $OUTPUT"
        ID="${OUTPUT%% *}"
        docker update --memory="$MEMORY" --memory-swap="$MEMORY" "$ID"
        docker inspect --format "{{.Id}} {{.HostConfig.Memory}} {{.HostConfig.MemorySwap}}" "$ID"
    fi
    sleep 30
done
