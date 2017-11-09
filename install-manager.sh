echo "Starting XAP..."

function print_input_parameter {
    key=$1
    value=$2
    echo "  $key = $value"
}

echo "Parsing input parameters..."

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    --xap-license)
    export XAP_LICENSE_KEY=$2
    print_input_parameter $key $2
    shift
    shift
    ;;
    --ssh-key)
    export SSH_PUBLIC_KEY=$2
    print_input_parameter $key $2
    shift
    shift
    ;;
    --azure-client-id)
    export AZURE_AUTH_CLIENT_ID=$2
    print_input_parameter $key $2
    shift
    shift
    ;;
    --azure-tenant-id)
    export AZURE_AUTH_TENANT_ID=$2
    print_input_parameter $key $2
    shift
    shift
    ;;
    --azure-client-secret)
    export AZURE_AUTH_CLIENT_SECRET=$2
    print_input_parameter $key $2
    shift
    shift
    ;;
    --azure-subscription-id)
    export AZURE_AUTH_SUBSCRIPTION_ID=$2
    print_input_parameter $key $2
    shift
    shift
    ;;
    --xap-blob-url)
    export XAP_BLOB_URL=$2
    print_input_parameter $key $2
    shift
    shift
    ;;
    --xap-rest-api-blob-url)
    export XAP_REST_API_BLOB_URL=$2
    print_input_parameter $key $2
    shift
    shift
    ;;
    *)
    POSITIONAL+=("$1")
    shift
    ;;
esac
done
set -- "${POSITIONAL[@]}"

echo ""
echo "Run installation"

xap_folder_name=$(basename $XAP_BLOB_URL .zip)
xap_home=/opt/$xap_folder_name
xap_envs=$xap_home/bin/setenv-overrides.sh
xap_plugins=$xap_home/lib/platform/manager/plugins

{
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
sudo wget -q -O $xap_plugins/rest-api.jar $XAP_REST_API_BLOB_URL

export EXT_JAVA_OPTIONS="-Dcom.gs.licensekey=$XAP_LICENSE_KEY"
export XAP_WEBUI_OPTIONS="-Dcom.gs.licensekey=$XAP_LICENSE_KEY"
export XAP_MANAGER_SERVERS=$(hostname)
} > /opt/install.log 2>&1

nohup $xap_home/bin/gs-agent.sh --manager > /opt/xap.log 2>&1 &

nohup $xap_home/bin/gs-webui.sh > /opt/webui.log 2>&1 &

echo "Startup script completed!"
