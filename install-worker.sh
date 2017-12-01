#!/bin/sh

echo "Starting XAP Worker..."

{
XAP_LICENSE_KEY=$1
MANAGER_IP=$2

echo "Parsing input parameters..."

while [ $# -gt 0 ]; do
    key="$1"
    echo "key = $key"
    case $key in
        --xap-license)
        echo "  $key = $2"
        export XAP_LICENSE_KEY="$2"
        echo "  XAP_LICENSE_KEY = $XAP_LICENSE_KEY"
        shift
        shift
        ;;
        --manager)
        echo "  $key = $2"
        export MANAGER_IP="$2"
        echo "  MANAGER_IP = $MANAGER_IP"
        shift
        shift
        ;;
        --xap-blob-url)
        echo "  $key = $2"
        export XAP_BLOB_URL="$2"
        echo "  XAP_BLOB_URL = $XAP_BLOB_URL"
        shift
        shift
        ;;
        *)
        echo "Unrecognized parameter: $key"
        shift
        ;;
    esac
done

xap_folder_name=$(basename $XAP_BLOB_URL .zip)
xap_home=/opt/$xap_folder_name
xap_envs=$xap_home/bin/setenv-overrides.sh

echo ">> Installing required packages"
sudo apt update
sudo apt -y install unzip
sudo apt -y install openjdk-8-jre-headless

echo ">> Download XAP"
sudo wget -q -O /opt/xap.zip $XAP_BLOB_URL

echo ">> Unzipping Xap archive"
sudo unzip -u -d /opt -q /opt/xap.zip

echo ">> Setup env variables"
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" | sudo tee --append $xap_envs > /dev/null

export EXT_JAVA_OPTIONS="-Dcom.gs.licensekey=$XAP_LICENSE_KEY"
export XAP_MANAGER_SERVERS=$MANAGER_IP
} > /opt/install.log 2>&1

nohup $xap_home/bin/gs-agent.sh --gsc=0 > /opt/xap.log 2>&1 &

echo "Startup script completed!"