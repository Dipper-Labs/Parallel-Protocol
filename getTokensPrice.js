const fs = require('fs');
const https = require('https')

const options = {
    hostname: 'api.coingecko.com',
    port: 443,
    path: '/api/v3/simple/price?ids=dipper-network,bitcoin,ethereum,binancecoin&vs_currencies=usd',
    method: 'GET'
}

function DoWork() {
    const req = https.request(options, res => {
        res.on('data', d => {
            process.stdout.write(d);
            fs.writeFile('tokens_price.json', d, (err) => {
                if (err) {
                    throw err;
                }
                console.log("prices saved");
            });
        })
    });

    req.on('error', error => {
        console.error(error)
    });

    req.end();
}

exports.DoWork = DoWork;