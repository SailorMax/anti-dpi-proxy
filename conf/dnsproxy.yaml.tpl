# This is the yaml configuration file for dnsproxy with minimal working
# configuration, all the options available can be seen with ./dnsproxy --help.
# To use it within dnsproxy specify the --config-path=/<path-to-config.yaml>
# option.  Any other command-line options specified will override the values
# from the config file.
# https://github.com/AdguardTeam/dnsproxy
---
bootstrap:
  - "${BOOTSTRAP_DNS}"
listen-addrs:
  - "0.0.0.0"
listen-ports:
  - 53
max-go-routines: 0
ratelimit: 0
ratelimit-subnet-len-ipv4: 24
ratelimit-subnet-len-ipv6: 64
udp-buf-size: 0
upstream:
  - "[/${DNSMASQ_STR}/]${DNS_FOR_DISPUTED_DOMAINS}"
  - "${DEFAULT_DNS}"  # Docker's DNS
timeout: '10s'
