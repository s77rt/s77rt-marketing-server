#!/usr/bin/env bash

VERSION="0.1.2"

echo "s77rt - Marketing Server v$VERSION (Centos 7.x)"

if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
	echo "FOR SECURITY REASONS YOU MUST NOT SOURCE THE SCRIPT!"
	echo "Use: bash ${BASH_SOURCE[0]}"
	return 1
fi

##########################################

getMainIP() {
	echo $(hostname -I | awk '{ for(i=1; i<=NF; i++){if ($i != "127.0.0.1" && $i != "::1"){ print $i; break}} }')
}

genPassword() {
	echo $(openssl rand -base64 15)
}

##########################################

echo "Checking DATA... (1/2)"

if [[ -z "$MW_L_MARKET_PLACE" ]]; then
	MW_L_MARKET_PLACE="envato"
fi
echo "MW_L_MARKET_PLACE: $MW_L_MARKET_PLACE"

if [[ -z "$MW_L_PURCHASE_CODE" ]]; then
	echo "MW_L_PURCHASE_CODE is not set!"
	exit 10
fi
echo "MW_L_PURCHASE_CODE: $MW_L_PURCHASE_CODE"

if [[ -z "$MW_DB_HOSTNAME" ]]; then
	MW_DB_HOSTNAME="localhost"
fi
echo "MW_DB_HOSTNAME: $MW_DB_HOSTNAME"

if [[ -z "$MW_DB_PORT" ]]; then
	MW_DB_PORT="3306"
fi
echo "MW_DB_PORT: $MW_DB_PORT"

if [[ -z "$MW_DB_USERNAME" ]]; then
	MW_DB_USERNAME="mailwizz_user"
fi
echo "MW_DB_USERNAME: $MW_DB_USERNAME"

if [[ -z "$MW_DB_PASSWORD" ]]; then
	MW_DB_PASSWORD=$(genPassword)
fi
echo "MW_DB_PASSWORD: $MW_DB_PASSWORD"

if [[ -z "$MW_DB_NAME" ]]; then
	MW_DB_NAME="mailwizz_db"
fi
echo "MW_DB_NAME: $MW_DB_NAME"

if [[ -z "$MW_DB_PREFIX" ]]; then
	MW_DB_PREFIX="mwx_"
fi
echo "MW_DB_PREFIX: $MW_DB_PREFIX"

if [[ -z "$MW_A_FIRSTNAME" ]]; then
	MW_A_FIRSTNAME="mailwizz"
fi
echo "MW_A_FIRSTNAME: $MW_A_FIRSTNAME"

if [[ -z "$MW_A_LASTNAME" ]]; then
	MW_A_LASTNAME="mailwizz"
fi
echo "MW_A_LASTNAME: $MW_A_LASTNAME"

if [[ -z "$MW_A_EMAIL" ]]; then
	echo "MW_A_EMAIL is not set!"
	exit 10
fi
echo "MW_A_EMAIL: $MW_A_EMAIL"

if [[ -z "$MW_A_PASSWORD" ]]; then
	MW_A_PASSWORD=$(genPassword)
fi
echo "MW_A_PASSWORD: $MW_A_PASSWORD"

if [[ -z "$MW_A_TIMEZONE" ]]; then
	MW_A_TIMEZONE="Africa/Algiers"
fi
echo "MW_A_TIMEZONE: $MW_A_TIMEZONE"

if [[ -z "$MW_A_CREATECUSTOMER" ]]; then
	MW_A_CREATECUSTOMER="yes"
fi
echo "MW_A_CREATECUSTOMER: $MW_A_CREATECUSTOMER"

export MW_L_MARKET_PLACE
export MW_L_PURCHASE_CODE
export MW_DB_HOSTNAME
export MW_DB_PORT
export MW_DB_USERNAME
export MW_DB_PASSWORD
export MW_DB_NAME
export MW_DB_PREFIX
export MW_A_FIRSTNAME
export MW_A_LASTNAME
export MW_A_EMAIL
export MW_A_PASSWORD
export MW_A_TIMEZONE
export MW_A_CREATECUSTOMER

if [[ -z "$MW_HOSTNAME" ]]; then
	MW_HOSTNAME=$(getMainIP)
fi
echo "MW_HOSTNAME: $MW_HOSTNAME"
export MW_HOSTNAME

MW_URL_BACKEND="http://$MW_HOSTNAME/backend"
MW_URL_CUSTOMER="http://$MW_HOSTNAME/customer"

export MW_URL_BACKEND
export MW_URL_CUSTOMER

export MYSQL_ROOT_PASSWORD=$(genPassword)

##########################################

echo "Checking DATA... (2/2)"
VALID_MW_L=$(curl -w "%{http_code}\n" -s -I -X GET -H "X-LICENSEKEY: $MW_L_PURCHASE_CODE" https://www.mailwizz.com/api/download/version/latest -o /dev/null)
if [ "$VALID_MW_L" != "200" ]; then
	echo "Invalid MailWizz License!"
	exit 20
fi
echo "OK"

##########################################

echo "Updating OS Packages..."
yum update -y
echo "Installing EPEL..."
cd utils/epel/
bash install.sh
bash configure.sh
bash start.sh
cd ../../
echo "Installing Prerequisites..."
yum install curl pwgen openssl expect nano unzip perl python3 python3-requests -y
echo "Installing MySQL..."
cd utils/mysql/
bash install.sh
bash configure.sh
bash start.sh
cd ../../
echo "Installing PHP..."
cd utils/php/
bash install.sh
bash configure.sh
bash start.sh
cd ../../
echo "Installing NGINX..."
cd utils/nginx/
bash install.sh
bash configure.sh
bash start.sh
cd ../../

##########################################

echo "Installing MailWizz..."
cd mailwizz
bash install.sh
bash configure.sh
bash start.sh
cd ..

##########################################

echo "Enabling IP Rotation..."
cd extras/ip-rotation/
bash enable.sh
cd ../../

##########################################


echo "DONE"
echo "##########################################"
echo "KEEP THOSE INFO SAFE"
echo "##########################################"
echo "MYSQL ROOT PASSWORD: $MYSQL_ROOT_PASSWORD"
echo "###"
echo "MailWizz DB Username: $MW_DB_USERNAME"
echo "MailWizz DB Password: $MW_DB_PASSWORD"
echo "MailWizz DB Name: $MW_DB_NAME"
echo "###"
echo "MailWizz Backend URL: $MW_URL_BACKEND"
echo "MailWizz Customer URL: $MW_URL_CUSTOMER"
echo "MailWizz Admin Email: $MW_A_EMAIL"
echo "MailWizz Admin Password: $MW_A_PASSWORD"
echo "##########################################"
echo "##########################################"

##########################################

history -c

##########################################
