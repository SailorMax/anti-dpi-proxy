const process = require('node:process');
const fs = require('node:fs');
const url = require('url');
const NodeUtils = require("node:util");
const ProxyChain = require("proxy-chain");

function ShuffleArray(arr) {
	var j, i = arr.length;
	while (i--) {
        j = Math.floor(Math.random() * (i + 1));
        [arr[i], arr[j]] = [arr[j], arr[i]];
    }
}

// setup config
const options = {
	host: {
		type: 'string',
		short: 'h',
		default: '127.0.0.1',
		help: 'host ip'
	},
	port: {
		type: 'string',
		short: 'p',
		default: '3128',
		help: 'port number'
	},
	verbose: {
		type: 'boolean',
		short: 'v',
		default: false,
		help: 'verbose logs'
	},
	proxies_file: {
		type: 'string',
		require: true,
		help: 'file with list of proxies. Sample: http://1.2.3.4:8080'
	},
	whitelist_file: {
		type: 'string',
		help: 'file with whitelist. All other sites will not use proxy.'
	},
};

const CONFIG = NodeUtils.parseArgs({ options, strict: false }).values;
try
{
	CONFIG.proxies = fs.readFileSync(CONFIG.proxies_file, 'utf8')
						.split(/\n/)
						.filter((el) => el.replace(/^#.*$/, ''));
	ShuffleArray(CONFIG.proxies);

	if (CONFIG.whitelist_file) {
		CONFIG.whitelist = fs.readFileSync(CONFIG.whitelist_file, 'utf8')
							.split(/\n/)
							.filter((el) => el.replace(/^#.*$/, ''));
	}
} catch (err) {
	console.error(err);
}

if (!CONFIG.proxies.length) {
	console.error('Proxy list is empty!');
	process.exit(255);
}

// init server
const server = new ProxyChain.Server({
	host: CONFIG.host,
	port: CONFIG.port,
	serverType: 'http',

	verbose: CONFIG.verbose,
	proxy_idx: 0,

	prepareRequestFunction: ({ hostname }) => {
		let upstreamProxy = null;
		if (CONFIG.whitelist) {
			for (const domain of CONFIG.whitelist) {
				const re = new RegExp('(^|\\.)'+domain.replaceAll('.', '\\.')+'$', "i");
				if (hostname.match(re)) {
					// take proxies by order, because list already shuffled
					if (--this.proxy_idx < 0)
						this.proxy_idx = CONFIG.proxies.length-1;
					upstreamProxy = CONFIG.proxies[ this.proxy_idx ];
				}
			}
		}
		if (CONFIG.whitelist && CONFIG.whitelist.indexOf(hostname) >= 0) {
			upstreamProxy = CONFIG.proxies[ Math.floor(Math.random() * CONFIG.proxies.length) ];
		}

		const prepare = {
			upstreamProxyUrl: upstreamProxy,
			ignoreUpstreamProxyCertificate: true,  // ready for self signed proxies
		};

		if (prepare.upstreamProxyUrl) {
			const choosedProxy = new url.URL(prepare.upstreamProxyUrl);
			choosedProxy.username = '';
			choosedProxy.password = '';
			console.log(`Request to ${hostname} via ${choosedProxy.toString()}`);
		}
		else {
			console.log(`Request to ${hostname} directly`);
		}

		return prepare;
	},
});

server.listen(() => {
	console.log(`Proxy server is listening on ${server.host}:${server.port}.`);
	console.log('List of actual proxies:');
	console.dir(CONFIG.proxies);
	console.log('Sites whitelist:');
	console.dir(CONFIG.whitelist || 'None');
});

server.on('connectionClosed', ({ connectionId, stats }) => {
	console.log(`Connection ${connectionId} closed`);
	console.dir(stats);
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
