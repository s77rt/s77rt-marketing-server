<?php

function get_public_ips() {
	$ips = [];
	$ips_tmp = explode(" ", trim(shell_exec("hostname -I")));
	foreach ($ips_tmp as $ip) {
		if (filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_IPV4 | FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE)) {
			array_push($ips, "ip4:".$ip);
		} else if (filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_IPV6 | FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE)) {
			array_push($ips, "ip6:".$ip);
		}
	}
	return $ips;
}

Yii::app()->hooks->addFilter('sending_domain_get_dns_txt_spf_record', function($record, $sendingDomain, $smtpHosts) {
	$smtpHostsFiltered = [];
	foreach ($smtpHosts as $smtphost) {
		if (!str_ends_with($smtphost, "localhost")) {
			array_push($smtpHostsFiltered, $smtphost);
		}
	}

	$smtpHosts = array_unique(array_merge(get_public_ips(), $smtpHostsFiltered));
	sort($smtpHosts);

	$spf = sprintf('v=spf1 mx %s ~all', implode(" ", $smtpHosts));
	$record = sprintf('%s.      IN TXT   "%s"', $sendingDomain->name, $spf);

	return $record;
});
