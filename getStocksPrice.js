const fs = require('fs');
const https = require('https')

const options = {
	hostname: 'hq.sinajs.cn',
	port: 443,
	path: '/list=gb_aapl,gb_tsla',
	method: 'GET'
}

let prices = {}

const req = https.request(options, res => {
	res.on('data',d => {
		process.stdout.write(d);
		fs.writeFileSync('StocksPrice.js', d, 'UTF-8');
	})
})

req.on('error', error => {
	console.error(error)
})

req.end()

setTimeout(()=>{
	const sp = require('./StocksPrice.js')
	console.log(sp.hq_str_gb_aapl);
}, 2000)
