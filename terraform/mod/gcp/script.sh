sudo apt-get update
sudo apt-get install --yes wget software-properties-common
sudo wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | sudo apt-key add -
sudo add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/

sudo apt-get update && sudo apt-get --yes install adoptopenjdk-11-hotspot

sudo curl -LO https://github.com/keycloak/keycloak/releases/download/16.0.0/keycloak-16.0.0.tar.gz
sudo tar -xvzf keycloak-16.0.0.tar.gz
