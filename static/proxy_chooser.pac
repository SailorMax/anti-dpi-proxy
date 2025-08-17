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
	// other
];

var sDomains4SockProxy = domains2proxy.map(function(v) { return v+'|*.'+v; }).join('|');
var aIpMasks4SockProxy = ips2proxy.map(function(ip_mask) {  
	var ip_mask_arr = ip_mask.split('/', 2);
	var cidr = ip_mask_arr[1];
	var net_mask = [];
	for (var i=0; i<4; i++) {
		var n = Math.min(cidr, 8);
		net_mask.push(256 - Math.pow(2, 8-n));
		cidr -= n;
	}
	return [ip_mask_arr[0], net_mask.join('.')];
});


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
	for (var ip_mask of aIpMasks4SockProxy)
		if (isInNet(host, ip_mask[0], ip_mask[1]))
			return proxy_command;

    // by default use no proxy
    return "DIRECT";
}
