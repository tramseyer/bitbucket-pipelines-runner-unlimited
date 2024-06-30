#!/bin/bash
while true
do
    OUTPUT=$(docker inspect --format="{{.Id}} {{.Name}} {{.HostConfig.CpuQuota}}" $(docker ps -aq) | grep ".*_build\s400000")
    if [ $? -eq 0 ]; then
        echo "Found *_build container with active CPU quota: $OUTPUT"
        ID="${OUTPUT%% *}"
        docker update --cpu-quota=-1 "$ID"
        docker inspect --format "{{.Id}} {{.HostConfig.CpuQuota}}" "$ID"
    fi
    sleep 10
done
