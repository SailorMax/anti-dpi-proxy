import process from 'node:process'
import url from 'node:url'
import ProxyChain from 'proxy-chain'

import { CONFIG } from './libs/cli_args.js';
import { CheckHostInWhitelistAsync } from './libs/whitelist_tools.js';

if (!CONFIG.proxies.length) {
	console.error('Proxy list is empty!');
	process.exit(255);
}

const server = new ProxyChain.Server({
	host: CONFIG.host,
	port: CONFIG.port,
	serverType: 'http',

	verbose: CONFIG.verbose,

	prepareRequestFunction: async function({ hostname }) {
		let upstreamProxy = null;

		if (typeof this.proxy_idx == "undefined")
			this.proxy_idx = 0;

		if (CONFIG.whitelist && await CheckHostInWhitelistAsync(hostname, CONFIG.whitelist)) {
			// take proxies by order, because list already shuffled
			if (--this.proxy_idx < 0)
				this.proxy_idx = CONFIG.proxies.length-1;
			upstreamProxy = CONFIG.proxies[ this.proxy_idx ];
		}

		const prepare = {
			upstreamProxyUrl: upstreamProxy,
			ignoreUpstreamProxyCertificate: true,  // ready for self signed proxies
		};

		if (prepare.upstreamProxyUrl) {
			const choosedProxy = new url.URL(prepare.upstreamProxyUrl);
			choosedProxy.username = '';
			choosedProxy.password = '';
		}

		return prepare;
	},
});

server.listen(() => {
	console.log(`Proxy server is listening on ${server.host}:${server.port}.`);
	console.log('Actual proxies: ' + CONFIG.proxies.length);
	console.log('Sites whitelist: ' + CONFIG.whitelist.length);
	console.log('Verbose output: ' + CONFIG.verbose);
});

server.on('connectionClosed', ({ connectionId, stats }) => {
	console.log(`Connection ${connectionId} closed with stats: ` + JSON.stringify(stats));
});

server.on('requestFailed', ({ request, error }) => {
	console.log(`Request ${request.url} failed`);
	console.error(error);
});

server.on('tlsError', ({ error }) => {
	console.error(error);
});

process.on('SIGTERM', () => {
	console.log('SIGTERM signal received: closing Proxy server');
	server.close(() => {
		console.log('Proxy server closed');
		process.exit(0);
	});
});
