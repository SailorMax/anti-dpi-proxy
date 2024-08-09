Anti DPI ([Deep packet inspection](https://en.wikipedia.org/wiki/Deep_packet_inspection)) proxy for custom domains list. Based on [Bypass DPI](https://github.com/hufrea/byedpi) solution and Docker container

The solution uses [PAC](https://developer.mozilla.org/en-US/docs/Web/HTTP/Proxy_servers_and_tunneling/Proxy_Auto-Configuration_PAC_file)-file to control proxy domains and make up 2 docker containers:
1. http-server (port 1081) for access to config file via http-protocol (Windows [doesn't support](https://learn.microsoft.com/en-us/previous-versions/troubleshoot/browsers/administration/cannot-read-pac-file) local files)
2. proxy-server (port 1080) based on [Bypass DPI](https://github.com/hufrea/byedpi)-solution

Both servers are only accessible on the local computer!

### Requirements:
1. [docker compose](https://docs.docker.com/compose/) or simply [docker](https://docs.docker.com/manuals/) (native, Docker Desktop or native Docker inside [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install))
2. internet


### How to use it:
0. make copy of `./static/proxy_chooser.js` in `./static` directory with your own domains list in shExpMatch() function
1. `docker compose up`
2. setup in your browser or system proxy configuration URL to http://127.0.0.1:1081/proxy_chooser.js (or your file name here)

( *alternative method to run only proxy: `docker run --rm -p 127.0.0.1:1080:1080 --name byedpi tazihad/byedpi --disorder 1 --fake 0 --ttl 1 --auto=torst --tlsrec 1+s --debug 1
`* )

### Benefits:
1. solution in local sandbox
2. you can control which domains traffic has to be modified
