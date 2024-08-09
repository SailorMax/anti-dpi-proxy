// https://developer.mozilla.org/en-US/docs/Web/HTTP/Proxy_servers_and_tunneling/Proxy_Auto-Configuration_PAC_file
function FindProxyForURL(url, host) {

    // use proxy for specific domains
    if (shExpMatch(host, "youtube.com|*.youtube.com|googlevideo.com|*.googlevideo.com|youtubei.googleapis.com|*.youtubei.googleapis.com|ytimg.com|*.ytimg.com"))
        // return "PROXY yourproxy:8080";
		return "SOCKS 127.0.0.1:1080";

    // by default use no proxy
    return "DIRECT";
}
