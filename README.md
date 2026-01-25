Anti DPI ([Deep packet inspection](https://en.wikipedia.org/wiki/Deep_packet_inspection)) proxy for custom domains list. Based on [Spoof DPI](https://github.com/xvzc/SpoofDPI) and [Bypass DPI](https://github.com/hufrea/byedpi) in Docker containers

The solution uses [PAC](https://developer.mozilla.org/en-US/docs/Web/HTTP/Proxy_servers_and_tunneling/Proxy_Auto-Configuration_PAC_file)-file to control proxy domains, DNS-over-HTTPS and make up docker containers:
1. http-server (port 8082) for access to config(PAC) file via http-protocol (Windows [doesn't support](https://learn.microsoft.com/en-us/previous-versions/troubleshoot/browsers/administration/cannot-read-pac-file) local files)
2. sock5-proxy-server (port 1080) based on [Bypass DPI](https://github.com/hufrea/byedpi)-solution
3. (optional) http-proxy-server (port 8888) based on [Spoof DPI](https://github.com/xvzc/SpoofDPI)-solution
4. (optional) dns-proxy-server (port 53) based on [DNS Proxy](https://github.com/AdguardTeam/dnsproxy)-solution
5. (optional) ext-proxy-server (port 3128) based on [Proxy-chain](https://github.com/apify/proxy-chain)-solution

All servers are only accessible for the local computer!


### Benefits:
1. local solution in local sandbox (no VPN or external proxy**)
2. you can control which domains traffic has to be modified or uses via random external proxy

** external proxies can be used for specific sites, which __answers__ blocked.


### Requirements:
1. [docker compose](https://docs.docker.com/compose/) or simply [docker](https://docs.docker.com/manuals/) (native, Docker Desktop or native Docker inside [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install))
2. internet


### How to use it:
0. setup list of required domains in `conf/disputed_domains.txt` or/and required ip masks in `conf/disputed_ips.txt`. Also you can fill `conf/ext_proxies.txt` by known proxies + `conf/ext_proxy_whitelist.txt` with domains, which answers are blocked. you can try to get proxies list by `scripts/ext_proxy_finder.sh`.
1. `docker compose up`
2. setup in your browser or system proxy configuration URL to http://127.0.0.1:8082/proxy_chooser.pac
3. (optional) setup in your browser or system DNS server 127.0.0.1(:53)

### Configuration hints:
- `ttl` has to be limited by your provider servers (`tracert/traceroute google.com`)

### If it doesn't work:
0. try to setup in your browser or system DNS server 127.0.0.1(:53)
1. try to find better arguments for "Bypass DPI". Details: https://github.com/hufrea/byedpi/blob/main/readme.txt
2. try to change PROXY_COMMAND variable to "PROXY 127.0.0.1:8888" in `docker-compose.yml` and find better arguments for "Spoof DPI". Details: https://spoofdpi.xvzc.dev/user-guide/https/
3. specific and not high traffic sites can be added to `conf/ext_proxy_whitelist.txt` if you have external proxies.
