#!/bin/bash

PORT_FORWARD_PID=$(lsof -t -i:18276)

if [[ -n "$PORT_FORWARD_PID" ]]; then
    kill "$PORT_FORWARD_PID" && echo "Port-forward closed, $PORT_FORWARD_PID killed"
else
    echo "No process found on port 18276"
fi
