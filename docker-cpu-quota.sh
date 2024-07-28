#!/bin/bash
while true
do
    for CONTAINER in $(docker ps -aq)
    do
        OUTPUT=$(docker inspect --format="{{.Id}} {{.Name}} {{.HostConfig.CpuQuota}}" "$CONTAINER" | grep ".*_build\s400000")
        if [ $? -eq 0 ]; then
            echo "Found *_build container with active CPU quota: $OUTPUT"
            ID="${OUTPUT%% *}"
            docker update --cpu-quota=-1 "$ID"
            docker inspect --format "{{.Id}} {{.HostConfig.CpuQuota}}" "$ID"
        fi
    done
    sleep 10
done
