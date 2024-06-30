#!/bin/bash
while true
do
    crictl ps -a | grep -E "Running\s+runner\s" | cut -d " " -f 1 | xargs -I {} crictl exec {} /bin/sh -c '
        OUTPUT=$(./docker inspect --format="{{.Id}} {{.Name}} {{.HostConfig.CpuQuota}}" $(./docker ps -aq) 2> /dev/null | grep ".*_build\s400000")
        if [ $? -eq 0 ]; then
            echo "Found *_build container with active CPU quota: $OUTPUT"
            ID="${OUTPUT%% *}"
            ./docker update --cpu-quota=-1 "$ID"
            ./docker inspect --format "{{.Id}} {{.HostConfig.CpuQuota}}" "$ID"
        fi
    '
    sleep 10
done
