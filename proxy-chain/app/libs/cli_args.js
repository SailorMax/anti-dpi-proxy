import process from 'node:process';
import fs from 'node:fs/promises';
import NodeUtils from 'node:util'


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

export const CONFIG = NodeUtils.parseArgs({ options, strict: false }).values;
try
{
	CONFIG.proxies = (await fs.readFile(CONFIG.proxies_file, { encoding: 'utf8' }))
							.replace("\r", '')
							.split(/\n/)
							.filter((el) => el.replace(/^#.*$/, ''));
	ShuffleArray(CONFIG.proxies);

	if (CONFIG.whitelist_file) {
		CONFIG.whitelist = (await fs.readFile(CONFIG.whitelist_file, { encoding: 'utf8' }))
							.replace("\r", '')
							.split(/\n/)
							.filter((el) => el.replace(/^#.*$/, ''));
	}
} catch (err) {
	console.error(err);
}
