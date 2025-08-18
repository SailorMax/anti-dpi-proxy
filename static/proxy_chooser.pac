var domains2proxy = [
    "youtube.com",
    "googlevideo.com",
    "youtu.be",
    "youtubei.googleapis.com",
    "ytimg.com",
    "rutracker.org",
    "rutracker.cc",
    "medium.com",
	"ntc.party",
    "linkedin.com",
    "x.com",
	"stackoverflow.com",
	"stackexchange.com",
];

var ips2proxy = [
	// https://core.telegram.org/resources/cidr.txt
	"91.108.56.0/22",
	"91.108.4.0/22",
	"91.108.8.0/22",
	"91.108.16.0/22",
	"91.108.12.0/22",
	"149.154.160.0/20",
	"91.105.192.0/23",
	"91.108.20.0/22",
	"185.76.151.0/24",
	"2001:b28:f23d::/48",
	"2001:b28:f23f::/48",
	"2001:67c:4e8::/48",
	"2001:b28:f23c::/48",
	"2a0a:f280::/32",
	// other
];

var sDomains4SockProxy = domains2proxy.map(function(v) { return v+'|*.'+v; }).join('|');
var aIpV4Masks4SockProxy = ips2proxy.map(function(ip_mask) {
	var ip_mask_arr = ip_mask.split('/', 2);
	var cidr = ip_mask_arr[1];
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
	var cidr = ip_mask_arr[1];
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
		for (idx in parts)
			if (parts[idx] === '') {
				var args = [];
				args[0] = idx-0;	// start
				args[1] = 1;		// count to delete
				while (to_add--) args.push('0');
				[].splice.apply(parts, args);
				if (parts[idx+1] === '') parts[idx+1] = '0';	// if '::' at end
				break;
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
	// var proxy_command = "PROXY 127.0.0.1:8888";
	var proxy_command = "SOCKS 127.0.0.1:1080";

    // use proxy for specific domains
    if (shExpMatch(host, sDomains4SockProxy))
		return proxy_command;

    // use proxy for specific ips
	var host_ip = dnsResolve(host) || host;
	var idx, ip_mask
	if (host_ip.indexOf(':') == -1) {
		for (idx in aIpV4Masks4SockProxy) {
			ip_mask = aIpV4Masks4SockProxy[idx];
			if (isInNet(host_ip, ip_mask[0], ip_mask[1]))
				return proxy_command;
		}
	} else {
		for (idx in aIpV6Masks4SockProxy) {
			ip_mask = aIpV6Masks4SockProxy[idx];
			if (isInNetV6(host_ip, ip_mask[0], ip_mask[1]))
				return proxy_command;
		}
	}

    // by default use no proxy
    return "DIRECT";
}

