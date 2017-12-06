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
        --xap-rest-api-blob-url)
        echo "  $key = $2"
        export XAP_REST_API_BLOB_URL="$2"
        echo "  XAP_REST_API_BLOB_URL = $XAP_REST_API_BLOB_URL"
        shift
        shift
        ;;
        --grid-user-name)
        echo "  $key = $2"
        export GRID_USER_NAME="$2"
        echo "  GRID_USER_NAME = $GRID_USER_NAME"
        shift
        shift
        ;;
         --grid-user-password)
        echo "  $key = $2"
        export GRID_USER_PASSWORD="$2"
        echo "  GRID_USER_PASSWORD = $GRID_USER_PASSWORD"
        shift
        shift
        ;;
        --grid-user-privileges)
        echo "  $key = $2"
        export GRID_USER_PRIVILEGES="$2"
        echo "  GRID_USER_PRIVILEGES = $GRID_USER_PRIVILEGES"
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

echo ">> Copy Rest API jar to $xap_home"
sudo wget -q -O /opt/cloud-deployment.jar $XAP_REST_API_BLOB_URL

echo ">> Setup env variables"
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" | sudo tee --append $xap_envs > /dev/null

export EXT_JAVA_OPTIONS_SECURITY="-Dcom.gs.security.enabled=true"
export EXT_JAVA_OPTIONS="-Dcom.gs.licensekey=$XAP_LICENSE_KEY $EXT_JAVA_OPTIONS_SECURITY"
export XAP_MANAGER_SERVERS=$MANAGER_IP
export XAP_HOME="$xap_home"

echo ">> Environment variables"
printenv

} > /opt/install.log 2>&1

java -cp /opt/cloud-deployment.jar:$xap_home/lib/required/xap-common.jar:$xap_home/lib/required/xap-datagrid.jar:$xap_home/lib/optional/security/xap-security.jar org.gigaspaces.cloud_deployment.utils.UserProvider > /opt/user-provider.log 2>&1

nohup $xap_home/bin/gs-agent.sh --gsc=0 > /opt/xap.log 2>&1 &

echo "Startup script completed!"