echo "Starting XAP..."

export XAP_LICENSE_KEY=$1
export SSH_PUBLIC_KEY=$2

xap_blob="https://xapblob.blob.core.windows.net/xap/gigaspaces-xap-12.2.0-ga-b18000.zip"
xap_rest_blob="https://xapblob.blob.core.windows.net/xap/rest-api.jar"

xap_folder_name=gigaspaces-xap-12.2.0-ga-b18000
xap_home=/opt/$xap_folder_name
xap_envs=$xap_home/bin/setenv-overrides.sh
xap_plugins=$xap_home/lib/platform/manager/plugins

{
echo ">> Installing required packages"
sudo apt -y install unzip
sudo apt -y install openjdk-8-jdk-headless

echo ">> Download XAP"
sudo wget -q -O /opt/xap.zip $xap_blob

echo ">> Unzipping Xap archive"
sudo unzip -u -d /opt -q /opt/xap.zip

echo ">> Setup env variables"
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" | sudo tee --append $xap_envs > /dev/null

echo ">> Copy Rest API jar to $xap_plugins"
sudo mkdir -p $xap_plugins
sudo wget -q -O $xap_plugins/rest-api.jar $xap_rest_blob

export EXT_JAVA_OPTIONS="-Dcom.gs.licensekey=$XAP_LICENSE_KEY"
export XAP_WEBUI_OPTIONS="-Dcom.gs.licensekey=$XAP_LICENSE_KEY"
export XAP_MANAGER_SERVERS=$(hostname)
} > /opt/install.log 2>&1

nohup $xap_home/bin/gs-agent.sh --manager > /opt/xap.log 2>&1 &

nohup $xap_home/bin/gs-webui.sh > /opt/webui.log 2>&1 &

echo "Startup script completed!"
