#!/bin/bash -eux

CONTAINER_RUNTIME="$1"
echo "CONTAINER_RUNTIME: $CONTAINER_RUNTIME"

cp "$CONTAINER_RUNTIME-cpu-quota.sh" /root/
cp "$CONTAINER_RUNTIME-cpu-quota.service" /etc/systemd/system/
systemctl enable "$CONTAINER_RUNTIME-cpu-quota"
systemctl start "$CONTAINER_RUNTIME-cpu-quota"
systemctl status --no-pager "$CONTAINER_RUNTIME-cpu-quota"

cp "$CONTAINER_RUNTIME-memory-limit.sh" /root/
cp "$CONTAINER_RUNTIME-memory-limit.service" /etc/systemd/system/
systemctl enable "$CONTAINER_RUNTIME-memory-limit"
systemctl start "$CONTAINER_RUNTIME-memory-limit"
systemctl status --no-pager "$CONTAINER_RUNTIME-memory-limit"
