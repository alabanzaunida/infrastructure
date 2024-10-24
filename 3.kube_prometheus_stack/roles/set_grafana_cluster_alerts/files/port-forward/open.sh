#!/bin/bash

PORT_FORWARD_PID=$(lsof -t -i:18276)

if [[ -n "$PORT_FORWARD_PID" ]]; then
    kill "$PORT_FORWARD_PID" && echo "Port-forward closed, $PORT_FORWARD_PID killed"
else
    echo "No process found on port 18276"
fi

microk8s kubectl port-forward -n observability svc/kube-prometheus-stack-grafana 18276:80 >/dev/null 2>&1 &

PORT_FORWARD_PID=$!
echo "Port-forward successfully opened in the background with PID: $PORT_FORWARD_PID"
