Anti DPI ([Deep packet inspection](https://en.wikipedia.org/wiki/Deep_packet_inspection)) proxy for custom domains list. Based on [Spoof DPI](https://github.com/xvzc/SpoofDPI) and [Bypass DPI](https://github.com/hufrea/byedpi) in Docker containers

The solution uses [PAC](https://developer.mozilla.org/en-US/docs/Web/HTTP/Proxy_servers_and_tunneling/Proxy_Auto-Configuration_PAC_file)-file to control proxy domains and make up docker containers:
1. http-server (port 8082) for access to config(PAC) file via http-protocol (Windows [doesn't support](https://learn.microsoft.com/en-us/previous-versions/troubleshoot/browsers/administration/cannot-read-pac-file) local files)
2. http-proxy-server (port 8888) based on [Spoof DPI](https://github.com/xvzc/SpoofDPI)-solution
3. (optional) sock5-proxy-server (port 1080) based on [Bypass DPI](https://github.com/hufrea/byedpi)-solution

All servers are only accessible on the local computer!


### Benefits:
1. local solution in local sandbox (no VPN or external proxy)
2. you can control which domains traffic has to be modified


### Requirements:
1. [docker compose](https://docs.docker.com/compose/) or simply [docker](https://docs.docker.com/manuals/) (native, Docker Desktop or native Docker inside [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install))
2. internet


### How to use it:
0. make copy of `./static/proxy_chooser.pac` in `./static` directory with your own domains list in shExpMatch() function
1. `docker compose up`
2. setup in your browser or system proxy configuration URL to http://127.0.0.1:8082/proxy_chooser.pac (or your file name here)

### Configuration:
- `ttl` has to be limited by your provider servers (`tracert/traceroute google.com`)

### If it doesn't work:
1. try to uncomment "sock5-proxy" block in `docker-compose.yml` and switch "PROXY"-string to "SOCKS"-string in PAC-file
2. try to find better arguments for "Bypass DPI". Details: https://github.com/hufrea/byedpi/blob/main/readme.txt
