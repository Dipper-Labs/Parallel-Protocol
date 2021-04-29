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
		let res = /hq_str_gb_aapl="[^,]*,(\d*\.\d*)/g.exec(d.toString());
		prices.aapl = res[1];
		res = /hq_str_gb_tsla="[^,]*,(\d*\.\d*)/g.exec(d.toString());
		prices.tsla = res[1];
		console.log(prices);

		const stocksPrice = JSON.stringify(prices, null, '\t');

		fs.writeFile('stocks_price.json', stocksPrice, (err) => {
			if (err) {
				throw err;
			}
			console.log("prices saved");
		});
	})
})

req.on('error', error => {
	console.error(error)
})

req.end()
