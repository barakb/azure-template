#!/bin/sh

echo "Starting XAP..."

echo "XAP License key"

XAP_LICENSE_KEY=$1

export EXT_JAVA_OPTIONS="-Dcom.gs.licensekey=$XAP_LICENSE_KEY"

nohup /opt/gigaspaces-xap/bin/gs-agent.sh --manager > /opt/xap.log 2>&1 &

echo "Startup script completed!"
