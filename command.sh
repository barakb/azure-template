#!/bin/sh

echo "Starting XAP..."

/opt/gigaspaces-insightedge-12.2.0-ga-b18015-628/bin/gs-agent.sh --manager-local > /opt/xap.log 2>&1

echo "Startup script completed!"
