const fs = require('fs');
const http = require('http');
const https = require('https');
const chardet = require('chardet');

const options = {};

let serverType = http;
let port = 80;

const tlsKey = 'server.key';
const tlsCert = 'server.cert';

if (fs.existsSync(tlsKey) && fs.existsSync(tlsCert)) {
	options.key = fs.readFileSync(tlsKey);
	options.cert = fs.readFileSync(tlsCert);
	serverType = https;
	port = 443
}

const server = serverType.createServer(options, function (request, response) {
	let body = [];
	request.on('data', (chunk) => {
		body.push(chunk);
	}).on('end', () => {
		const timestamp=  Date.now();
		const headers = request && request.headers;
		// console.log('FULL REQUEST: ', request);
		let charSet;
		body = Buffer.concat(body).toString();
		try {
			charSet = chardet.detect(Buffer.from(body));
		} catch (e) {
			console.log('error attempting to detect character set: ', e);
		}
		const urlMethod = `Request Method: ${request.method} || URL: ${request.url} || Body character Set: ${charSet}`;
		console.log(`******************** REQUEST BEGIN **********************`);
		console.log(urlMethod);
		console.log(`*********************************************************`);
		console.log('********************* BODY BEGIN ************************');
		console.log(body);
		console.log('********************* BODY END **************************');
		console.log(`*********************************************************`);
		console.log('********************* HEADERS BEGIN *********************');
		console.log(headers);
		console.log('********************* HEADERS END ***********************');
		console.log('***************** DETECTED CHARACTER SET ****************');
		console.log(charSet);
		console.log('******************* REQUEST END *************************');
		fs.writeFileSync(`${timestamp}-request.txt`,urlMethod+'\n\n'+'Headers:\n'+JSON.stringify(headers));
		fs.writeFileSync(`${timestamp}-body.txt`,body);
		response.end();
	});
})


server.listen(port);

console.log('requestLogger listening on port '+port)
