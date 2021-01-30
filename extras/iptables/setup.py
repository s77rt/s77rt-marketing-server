#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import subprocess

SSH_PORT = 22
HTTP_PORT = 80
HTTPS_PORT = 443
SMTP_PORTS = [25, 465, 587]

def getInterface() -> str:
	p1 = subprocess.Popen(['route'], stdout=subprocess.PIPE)
	p2 = subprocess.Popen(['grep', '^default'], stdin=p1.stdout, stdout=subprocess.PIPE)
	p1.stdout.close()
	p3 = subprocess.Popen(['grep', '-o', '[^ ]*$'], stdin=p2.stdout, stdout=subprocess.PIPE)
	p2.stdout.close()
	out, _ = p3.communicate()
	return out.decode().split()[0]

def getIPs() -> list:
	p = subprocess.Popen(['hostname','-I'], stdout=subprocess.PIPE)
	out, _ = p.communicate()
	return out.decode().split()

def filterIPs(ips) -> list:
	filtered_ips = []
	for ip in ips:
		if ip != "127.0.0.1" and ip != "::1":
			filtered_ips.append(ip)
	return filtered_ips

def enable_SSHPort() -> None:
	cmd = "iptables -A INPUT -p tcp -m state --state NEW --dport {port} -j ACCEPT".format(port=SSH_PORT)
	p = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
	p.communicate()

def enable_HTTPPort() -> None:
	cmd = "iptables -A INPUT -p tcp -m state --state NEW --dport {port} -j ACCEPT".format(port=HTTP_PORT)
	p = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
	p.communicate()

def enable_HTTPSPort() -> None:
	cmd = "iptables -A INPUT -p tcp -m state --state NEW --dport {port} -j ACCEPT".format(port=HTTPS_PORT)
	p = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
	p.communicate()

def enable_IPRotation(interface, ips) -> None:
	if len(ips) > 1:
		for port in SMTP_PORTS:
			for i, ip in enumerate(ips):
				i += 1
				cmd = "iptables -t nat -I POSTROUTING -m state --state NEW -p tcp --dport {port} -o {interface} -m statistic --mode nth --every {i} --packet 0 -j SNAT --to-source {ip}".format(
					port=port,
					interface=interface,
					i=i,
					ip=ip,
				)
				p = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
				p.communicate()


def flush_iptables() -> None:
	for cmd in [
		"iptables -P INPUT ACCEPT",
		"iptables -P FORWARD ACCEPT",
		"iptables -P OUTPUT ACCEPT",
		"iptables -t nat -F",
		"iptables -t mangle -F",
		"iptables -F",
		"iptables -X",
	]:
		p = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
		p.communicate()

def pre_iptables() -> None:
	for cmd in [
		"iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT",
		"iptables -A INPUT -p icmp -j ACCEPT",
		"iptables -A INPUT -i lo -j ACCEPT",
	]:
		p = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
		p.communicate()

def post_iptables() -> None:
	for cmd in [
		"iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited",
		"iptables -A FORWARD -j REJECT --reject-with icmp-host-prohibited",
	]:
		p = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
		p.communicate()

def save_iptables() -> None:
	iptables_config_file = '/etc/iptables.conf'
	if os.path.exists(iptables_config_file):
		append_write = 'a'
	else:
		append_write = 'w'
	f = open(iptables_config_file, append_write)
	cmd = ['iptables-save']
	p = subprocess.Popen(cmd, stdout=f)
	p.communicate()

	rc_local_file = '/etc/rc.d/rc.local'
	if os.path.exists(rc_local_file):
		append_write = 'a'
	else:
		append_write = 'w'
	f = open(rc_local_file, append_write)
	cmd = ['echo', 'iptables-restore < {}'.format(iptables_config_file)]
	p = subprocess.Popen(cmd, stdout=f)
	p.communicate()

	cmd = ['chmod', '+x', rc_local_file]
	p = subprocess.Popen(cmd, stdout=subprocess.PIPE)
	p.communicate()

def main() -> None:
	try:
		interface = getInterface()
		available_ips = getIPs()
		available_ips = filterIPs(available_ips)

		flush_iptables()

		pre_iptables()

		print("Enabling SSH Port", SSH_PORT)
		enable_SSHPort()

		print("Enabling HTTP Port", HTTP_PORT)
		enable_HTTPPort()

		print("Enabling HTTPS Port", HTTPS_PORT)
		enable_HTTPSPort()

		print("Enabling IP Rotation...", SMTP_PORTS)
		enable_IPRotation(interface, available_ips)

		post_iptables()

		save_iptables()
	except Exception as e:
		print("Can't setup iptables", e)

if __name__ == '__main__':
	main()
