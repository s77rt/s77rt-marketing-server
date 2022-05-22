#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from os import environ
from requests import Session

# License
LICENSE = {
	'market_place': environ.get('MW_L_MARKET_PLACE'),
	'purchase_code': environ.get('MW_L_PURCHASE_CODE'),
}

# Meta
META = {
	'site_name': environ.get('MW_M_SITE_NAME'),
	'site_tagline': environ.get('MW_M_SITE_TAGLINE'),
	'site_description': environ.get('MW_M_SITE_DESCRIPTION'),
}

# Database
DB = {
	'hostname': environ.get('MW_DB_HOSTNAME'),
	'port': environ.get('MW_DB_PORT'),
	'username': environ.get('MW_DB_USERNAME'),
	'password': environ.get('MW_DB_PASSWORD'),
	'name': environ.get('MW_DB_NAME'),
	'prefix': environ.get('MW_DB_PREFIX')
}

# Admin
ADMIN = {
	'first_name': environ.get('MW_A_FIRSTNAME'),
	'last_name': environ.get('MW_A_LASTNAME'),
	'email': environ.get('MW_A_EMAIL'),
	'password': environ.get('MW_A_PASSWORD'),
	'timezone': environ.get('MW_A_TIMEZONE'),
	'create_customer': environ.get('MW_A_CREATECUSTOMER'),
}

HOSTNAME = str(environ.get('MW_HOSTNAME'))

def main() -> None:
	s = Session()
	s.post("http://"+HOSTNAME+"/install/index.php?route=welcome", data={
		'market_place': LICENSE['market_place'],
		'purchase_code': LICENSE['purchase_code'],
		'site_name': META['site_name'],
		'site_tagline': META['site_tagline'],
		'site_description': META['site_description'],
		'terms_consent': 1,
		'next': 1
	})
	s.post("http://"+HOSTNAME+"/install/index.php?route=requirements", data={
		'result': 1
	})
	s.post("http://"+HOSTNAME+"/install/index.php?route=filesystem", data={
		'result': 1
	})
	s.post("http://"+HOSTNAME+"/install/index.php?route=database", data={
		'hostname': DB['hostname'],
		'port': DB['port'],
		'username': DB['username'],
		'password': DB['password'],
		'dbname': DB['name'],
		'prefix': DB['prefix'],
		'next': 1
	})
	s.post("http://"+HOSTNAME+"/install/index.php?route=admin", data={
		'first_name': ADMIN['first_name'],
		'last_name': ADMIN['last_name'],
		'email': ADMIN['email'],
		'password': ADMIN['password'],
		'timezone': ADMIN['timezone'],
		'create_customer': ADMIN['create_customer'],
		'next': 1
	})

if __name__ == '__main__':
	main()
