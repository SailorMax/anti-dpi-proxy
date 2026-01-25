var proxy_command = "${PROXY_COMMAND}";
var ext_proxy_command = "${EXT_PROXY_COMMAND}";  // temporary solution, while dpi proxies doesn't support upstream proxy

// domain masks (uses as "name or *.name")
var domains2proxy = [
	${DOMAINS_JS_LIST}
];

var ips2proxy = [
	${IPS_JS_LIST}
];

var extProxyWhiteList = [
	${EXT_PROXY_WHITELIST_JS_LIST}
];

var sDomains4ExtProxy = extProxyWhiteList.map(function(v) { return v+'|*.'+v; }).join('|');
var sDomains4SockProxy = domains2proxy.map(function(v) { return v+'|*.'+v; }).join('|');
var aIpV4Masks4SockProxy = ips2proxy.map(function(ip_mask) {
	var ip_mask_arr = ip_mask.split('/', 2);
	var cidr = ip_mask_arr[1] || 32;
	var i, net_mask = [];
	if (ip_mask_arr[0].indexOf(':') < 0) {	// ipv4
		for (i=0; i<4; i++) {
			var n = Math.min(cidr, 8);
			net_mask.push(256 - Math.pow(2, 8-n));
			cidr -= n;
		}
		return [ip_mask_arr[0], net_mask.join('.')];
	}
	return null;
}).filter(function(v) { return v !== null; });
var aIpV6Masks4SockProxy = ips2proxy.map(function(ip_mask) {
	var ip_mask_arr = ip_mask.split('/', 2);
	var cidr = ip_mask_arr[1] || 128;
	var i, net_mask = [];
	if (ip_mask_arr[0].indexOf(':') > 0) {	// ipv6
		for (i=0; i<8; i++) {
			var n = Math.min(cidr, 16);
			net_mask.push((65536 - Math.pow(2, 16-n)).toString(16));
			cidr -= n;
		}
		return [ip_mask_arr[0], net_mask.join(':')];
	}
	return null;
}).filter(function(v) { return v !== null; });

function v6_as_arr(ip)
{
	var parts = ip.split(':');
	if (parts.length < 8) {
		var idx, to_add = 8 - parts.length + 1;
		for (idx in parts) {
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
	}

	return parts.map(function(v) { return parseInt(v, 16) });
}

function isInNetV6(host, mask, cidr)
{
	var inum_pos = host.indexOf('%');
	if (inum_pos > 0)
		host = host.substr(0, inum_pos);
	var host_arr = v6_as_arr(host);
	var mask_arr = v6_as_arr(mask);
	var cidr_arr = v6_as_arr(cidr);
	var i;
	for (i=0; i<8; i++)	{
		if ((host_arr[i] & cidr_arr[i]) != (mask_arr[i] & cidr_arr[i]))
			return false;
	}
	return true;
}

// https://developer.mozilla.org/en-US/docs/Web/HTTP/Proxy_servers_and_tunneling/Proxy_Auto-Configuration_PAC_file
// https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Proxy_servers_and_tunneling/Proxy_Auto-Configuration_PAC_file
function FindProxyForURL(url, host)
{
	// use ext proxy for specific domains
	if (ext_proxy_command != '' && shExpMatch(host, sDomains4ExtProxy))
		return ext_proxy_command;

	// use proxy for specific domains
	if (shExpMatch(host, sDomains4SockProxy))
		return proxy_command;

	// use proxy for specific ips
	var host_ip = dnsResolve(host) || host;
	var idx, ip_mask
	if (host_ip.indexOf('.') > 0) {  // ipv4
		for (idx in aIpV4Masks4SockProxy) {
			ip_mask = aIpV4Masks4SockProxy[idx];
			if (isInNet(host_ip, ip_mask[0], ip_mask[1]))
				return proxy_command;
		}

	} else if (host_ip.indexOf(':') > 0) {  // ipv6
		for (idx in aIpV6Masks4SockProxy) {
			ip_mask = aIpV6Masks4SockProxy[idx];
			if (isInNetV6(host_ip, ip_mask[0], ip_mask[1]))
				return proxy_command;
		}
	}

	// by default use no proxy
	return "DIRECT";
}
