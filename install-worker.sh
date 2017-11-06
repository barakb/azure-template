echo "Starting XAP Worker..."

XAP_LICENSE_KEY=$1

xap_blob="https://xapblob.blob.core.windows.net/xap/gigaspaces-xap-12.2.0-ga-b18000.zip"

xap_folder_name=gigaspaces-xap-12.2.0-ga-b18000
xap_home=/opt/$xap_folder_name
xap_envs=$xap_home/bin/setenv-overrides.sh

{
echo ">> Installing required packages"
sudo apt -y install unzip
sudo apt -y install openjdk-8-jre-headless

echo ">> Download XAP"
sudo wget -O /opt/xap.zip $xap_blob

echo ">> Unzipping Xap archive"
sudo unzip -u -d /opt -q /opt/xap.zip

echo ">> Setup env variables"
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" | sudo tee --append $xap_envs > /dev/null

export EXT_JAVA_OPTIONS="-Dcom.gs.licensekey=$XAP_LICENSE_KEY"
} > /opt/install.log 2>&1

nohup $xap_home/bin/gs-agent.sh --gsc=1 > /opt/xap.log 2>&1 &

echo "Startup script completed!"
