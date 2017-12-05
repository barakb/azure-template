#!/bin/sh

echo "Starting XAP..."

{
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
        --ssh-key)
        echo "  $key = $2"
        export SSH_PUBLIC_KEY="$2"
        echo "  SSH_PUBLIC_KEY = $SSH_PUBLIC_KEY"
        shift
        shift
        ;;
        --azure-client-id)
        echo "  $key = $2"
        export AZURE_AUTH_CLIENT_ID="$2"
        echo "  AZURE_AUTH_CLIENT_ID = $AZURE_AUTH_CLIENT_ID"
        shift
        shift
        ;;
        --azure-tenant-id)
        echo "  $key = $2"
        export AZURE_AUTH_TENANT_ID="$2"
        echo "  AZURE_AUTH_TENANT_ID = $AZURE_AUTH_TENANT_ID"
        shift
        shift
        ;;
        --azure-client-secret)
        echo "  $key = $2"
        export AZURE_AUTH_CLIENT_SECRET="$2"
        echo "  AZURE_AUTH_CLIENT_SECRET = $AZURE_AUTH_CLIENT_SECRET"
        shift
        shift
        ;;
        --azure-subscription-id)
        echo "  $key = $2"
        export AZURE_AUTH_SUBSCRIPTION_ID="$2"
        echo "  AZURE_AUTH_SUBSCRIPTION_ID = $AZURE_AUTH_SUBSCRIPTION_ID"
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
        --install-script-base)
        echo "  $key = $2"
        export INSTALL_WORKER_SCRIPT_BASE="$2"
        echo "  INSTALL_WORKER_SCRIPT_BASE = $INSTALL_WORKER_SCRIPT_BASE"
        shift
        shift
        ;;
        --install-worker-script-name)
        echo "  $key = $2"
        export INSTALL_WORKER_SCRIPT_NAME="$2"
        echo "  INSTALL_WORKER_SCRIPT_NAME = $INSTALL_WORKER_SCRIPT_NAME"
        shift
        shift
        ;;
        --azure-resource-group)
        echo "  $key = $2"
        export AZURE_RESOURCE_GROUP="$2"
        echo "  AZURE_RESOURCE_GROUP = $AZURE_RESOURCE_GROUP"
        shift
        shift
        ;;
        --azure-network)
        echo "  $key = $2"
        export AZURE_NETWORK="$2"
        echo "  AZURE_NETWORK = $AZURE_NETWORK"
        shift
        shift
        ;;
        --azure-worker-subnet)
        echo "  $key = $2"
        export AZURE_WORKER_SUBNET="$2"
        echo "  AZURE_WORKER_SUBNET = $AZURE_WORKER_SUBNET"
        shift
        shift
        ;;
        --azure-region)
        echo "  $key = $2"
        export AZURE_REGION="$2"
        echo "  AZURE_REGION = $AZURE_REGION"
        shift
        shift
        ;;
        --manager-vm-username)
        echo "  $key = $2"
        export MANAGER_VM_USERNAME="$2"
        echo "  MANAGER_VM_USERNAME = $MANAGER_VM_USERNAME"
        shift
        shift
        ;;
        --worker-name-prefix)
        echo "  $key = $2"
        export WORKER_NAME_PREFIX="$2"
        echo "  WORKER_NAME_PREFIX = $WORKER_NAME_PREFIX"
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

echo ""
echo "Run installation..."

xap_folder_name=$(basename $XAP_BLOB_URL .zip)
xap_home=/opt/$xap_folder_name
xap_envs=$xap_home/bin/setenv-overrides.sh
xap_plugins=$xap_home/lib/platform/manager/plugins


echo ">> Working variables:"
echo "   - xap_folder_name = $xap_folder_name"
echo "   - xap_home        = $xap_home"
echo "   - xap_envs        = $xap_envs"
echo "   - xap_plugins     = $xap_plugins"

echo ">> Installing required packages"
sudo apt -y install unzip
sudo apt -y install openjdk-8-jdk-headless

echo ">> Download XAP"
sudo wget -q -O /opt/xap.zip $XAP_BLOB_URL

echo ">> Unzipping Xap archive"
sudo unzip -u -d /opt -q /opt/xap.zip

echo ">> Setup env variables"
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" | sudo tee --append $xap_envs > /dev/null

echo ">> Copy Rest API jar to $xap_plugins"
sudo mkdir -p $xap_plugins
sudo wget -q -O $xap_plugins/cloud-deployment.jar $XAP_REST_API_BLOB_URL

echo ">> Fix jackson dependency" # TODO FIX ME
jackson_lib_folder="$xap_home/lib/optional/jackson"
jackson_base_url="http://central.maven.org/maven2/com/fasterxml/jackson/core"

rm $jackson_lib_folder/*

sudo wget -q -O "$jackson_lib_folder/jackson-annotations-2.7.0.jar" "$jackson_base_url/jackson-annotations/2.7.0/jackson-annotations-2.7.0.jar"
sudo wget -q -O "$jackson_lib_folder/jackson-core-2.7.2.jar" "$jackson_base_url/jackson-core/2.7.2/jackson-core-2.7.2.jar"
sudo wget -q -O "$jackson_lib_folder/jackson-databind-2.7.2.jar" "$jackson_base_url/jackson-databind/2.7.2/jackson-databind-2.7.2.jar"

echo ">> Export env variables"

export XAP_MANAGER_OPTIONS="$XAP_MANAGER_OPTIONS -Dcom.gs.manager.rest.ssl.enabled=true"
export EXT_JAVA_OPTIONS_SECURITY="-Dcom.gs.security.enabled=true"
export EXT_JAVA_OPTIONS="-Dcom.gs.licensekey=$XAP_LICENSE_KEY $EXT_JAVA_OPTIONS $EXT_JAVA_OPTIONS_SECURITY"
export XAP_WEBUI_OPTIONS="-Dcom.gs.licensekey=$XAP_LICENSE_KEY"
export XAP_MANAGER_SERVERS=$(hostname)
} > /opt/install.log 2>&1

nohup $xap_home/bin/gs-agent.sh --manager > /opt/xap.log 2>&1 &

nohup $xap_home/bin/gs-webui.sh > /opt/webui.log 2>&1 &

echo "Startup script completed!"
