var dpi_proxy_command = "${DPI_PROXY_COMMAND}";
var ext_proxy_command = "${EXT_PROXY_COMMAND}";  // temporary solution, while dpi proxies doesn't support upstream proxy

// domain masks (uses as "name or *.name")
var domains2dpi_proxy = [
	${DPI_PROXY_DOMAINS_JS_LIST}
];

var domains2ext_proxy = [
	${EXT_PROXY_DOMAINS_JS_LIST}
];

// functions
function get_ip_version(ip) {
	// ipv4
	if (ip.indexOf('.') > 0 && ip.match(/^(\d{1,3}\.){3}\d{1,3}(\/\d{1,2}$|$)/))
		return 4;
	// ipv6
	if (ip.indexOf(':') > 0 && ip.match(/:/g).length > 1)
		return 6;
	return null;
}

function get_ip_mask(ip_mask) {
	var ip_mask_arr = ip_mask.split('/', 2);
	var i, net_mask = [];

	switch (get_ip_version(ip_mask)) {
		case 4:
		   	var cidr = ip_mask_arr[1] || 32;
			for (i=0; i<4; i++) {
		 		var n = Math.min(cidr, 8);
		 		net_mask.push(256 - Math.pow(2, 8-n));
		 		cidr -= n;
			}
			return [ip_mask_arr[0], net_mask.join('.')];

		case 6:
		   	var cidr = ip_mask_arr[1] || 128;
			for (i=0; i<8; i++) {
		 		var n = Math.min(cidr, 16);
		 		net_mask.push((65536 - Math.pow(2, 16-n)).toString(16));
		 		cidr -= n;
			}
			return [ip_mask_arr[0], net_mask.join(':')];
  	}

   	return null;
}

function v6_as_arr(ip) {
	var parts = ip.split(':');
	if (parts.length < 8) {
		var idx, to_add = 8 - parts.length + 1;
		for (idx in parts)
			if (parts[idx] === '') {
				var args = [];
				args[0] = idx-0;	// start
				args[1] = 1;		// count to delete
				while (to_add--) args.push('0');
				[].splice.apply(parts, args);
				if (parts[idx+1] === '')	// if '::' at end
					parts[idx+1] = '0';
				break;
			}
	}

	return parts.map(function(v) { return parseInt(v, 16) });
}

// emulate isInNet for ipv6
function isInNetV6(host, mask, cidr) {
	var inum_pos = host.indexOf('%');
	if (inum_pos > 0)
		host = host.substr(0, inum_pos);
	var host_arr = v6_as_arr(host);
	var mask_arr = v6_as_arr(mask);
	var cidr_arr = v6_as_arr(cidr);
	for (var i=0; i<8; i++)
		if ((host_arr[i] & cidr_arr[i]) != (mask_arr[i] & cidr_arr[i]))
			return false;

	return true;
}

function is_host_in_list(host, whitelist) {
	// check host
	if (shExpMatch(host, whitelist.map(function (v) { return v + '|*.' + v; }).join('|')))
  		return true;

	// check ip
	var ip_mask, host_ip = get_ip_version(host) ? host : (dnsResolve(host) || host);
	for (idx in whitelist)
		if (ip_mask = get_ip_mask(whitelist[idx]))
			if ((ip_mask[0].indexOf('.') > 0 && isInNet(host_ip, ip_mask[0], ip_mask[1]))
				|| (ip_mask[0].indexOf(':') > 0 && isInNetV6(host_ip, ip_mask[0], ip_mask[1]))
				)
				return true;

  return false;
}

// https://developer.mozilla.org/en-US/docs/Web/HTTP/Proxy_servers_and_tunneling/Proxy_Auto-Configuration_PAC_file
// https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Proxy_servers_and_tunneling/Proxy_Auto-Configuration_PAC_file
function FindProxyForURL(url, host) {
	// use ext proxy for specific domains
	if (ext_proxy_command != '' && is_host_in_list(host, domains2ext_proxy))
		return ext_proxy_command;

	// use dpi proxy for specific domains
	if (dpi_proxy_command != '' && is_host_in_list(host, domains2dpi_proxy))
		return dpi_proxy_command;

	// by default use no proxy
	return "DIRECT";
}
