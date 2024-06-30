#!/bin/bash
while true
do
    crictl ps -a | grep -E "Running\s+runner\s" | cut -d " " -f 1 | xargs -I {} crictl exec {} /bin/sh -c '
        MEMORY=$((1024 * 1024 * 1024 * 1024)) # 1TB
        OUTPUT=$(./docker inspect --format="{{.Id}} {{.Name}} {{.HostConfig.Memory}} {{.HostConfig.MemorySwap}}" $(./docker ps -aq) 2> /dev/null | grep ".*_build" | grep -v "_build\s$MEMORY")
        if [ $? -eq 0 ]; then
            echo "Found *_build container with different memory limit: $OUTPUT"
            ID="${OUTPUT%% *}"
            ./docker update --memory="$MEMORY" --memory-swap="$MEMORY" "$ID"
            ./docker inspect --format "{{.Id}} {{.HostConfig.Memory}} {{.HostConfig.MemorySwap}}" "$ID"
        fi
    '
    sleep 30
done
