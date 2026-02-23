import dns from 'node:dns/promises'
import net from 'node:net'

function GetIpVersion(ip) {
	// ipv4
	if (ip.indexOf('.') > 0 && ip.match(/^(\d{1,3}\.){3}\d{1,3}(\/\d{1,2}$|$)/))
		return 4;
	// ipv6
	if (ip.indexOf(':') > 0 && ip.match(/:/g).length > 1)
		return 6;
	return null;
}

var resolver = new dns.Resolver({ timeout:2000 });
resolver.setServers([process.env.DNS_PROXY_IP]);
var host_ipv4 = {};
var host_ipv6 = {};
async function GetHostIp(host, ver) {
	var ip;
	if (ver == 4) {
		ip = host_ipv4[host] ? host_ipv4[host] : (await resolver.resolve4(host))[0];
		host_ipv4[host] = ip;
	} else if (ver == 6) {
		ip = host_ipv6[host] ? host_ipv6[host] : (await resolver.resolve6(host))[0];
		host_ipv6[host] = ip;
	}
	return ip
}

function CheckByDomain(hostname, whitelist) {
	for (const wl_domain of whitelist) {
		// filter only domains whitelist
		if (wl_domain.indexOf('/') > 0)
			continue;

		const re = new RegExp('(^|\\.)'+wl_domain.replaceAll('.', '\\.')+'$', "i");
		if (hostname.match(re)) {
			console.log(`found ${hostname} in whitelist`);
			return true;
		}
	}
	return false;
}

async function CheckByIpAsync(hostname, whitelist) {
	for (const wl_domain of whitelist) {
		// filter only ip whitelist
		var ip_ver = GetIpVersion(wl_domain);
		if (ip_ver === null)
			continue;

		// get host ip
		var host_ip_ver = GetIpVersion(hostname);
		var host_ip;
		if (host_ip_ver === null) {
			host_ip = await GetHostIp(hostname, ip_ver);
		} else if (host_ip_ver == ip_ver) {
			host_ip = hostname;
		} else {
			// hostname is ip of wrong version
			continue;
		}

		// prepare ip mask
		var ip_mask_arr = wl_domain.split('/', 2);
		if (ip_mask_arr[1] === '')
			ip_mask_arr[1] = (ip_ver == 4 ? 32 : 128);

		// check mask
		const blockList = new net.BlockList();
		blockList.addSubnet(ip_mask_arr[0], ip_mask_arr[1]-0, (ip_ver == 4 ? 'ipv4' : 'ipv6'));
		if (blockList.check(host_ip)) {
			console.log(`matched ${host_ip}(${hostname}) with whitelist's ${wl_domain}`);
			return true;
		}
	}
	return false;
}

export async function CheckHostInWhitelistAsync(hostname, whitelist) {

	if (CheckByDomain(hostname, whitelist))
		return true;

	if (await CheckByIpAsync(hostname, whitelist))
		return true;

	console.log(`${hostname} not found in whitelist`);
	return false;
}
