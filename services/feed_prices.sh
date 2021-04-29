export MNENOMIC="viable force length powder once neutral guilt test pottery walnut finish recipe"

for ((i=1;i<10000;i++))
do
	date
	echo "feed price for ${i} time"
	
	node getStocksPrice.js
	node getTokensPrice.js
	truffle migrate --network bsctestnet --skip-dry-run -f 11
	sleep 10
done

