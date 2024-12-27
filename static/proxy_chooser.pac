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
];

var sDomains4SockProxy = domains2proxy.map(function(v) { return v+'|*.'+v; }).join('|');

// https://developer.mozilla.org/en-US/docs/Web/HTTP/Proxy_servers_and_tunneling/Proxy_Auto-Configuration_PAC_file
function FindProxyForURL(url, host)
{
    // use proxy for specific domains
    if (shExpMatch(host, sDomains4SockProxy))
        // return "PROXY 127.0.0.1:8888";
		return "SOCKS 127.0.0.1:1080";

    // by default use no proxy
    return "DIRECT";
}
