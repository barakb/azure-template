#!/bin/sh

echo "Starting XAP...3"

nohup /opt/gigaspaces-xap/bin/gs-agent.sh --manager > /opt/xap.log 2>&1 &

echo "Startup script completed!"
