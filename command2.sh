#!/bin/sh

echo "Starting XAP...2"

nohup /opt/gigaspaces-insightedge-12.2.0-ga-b18015-628/bin/gs-agent.sh --manager-local > /opt/xap.log 2>&1 &

echo "Startup script completed!"
