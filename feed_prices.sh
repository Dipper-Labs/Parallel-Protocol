if [[ -z $MNENOMIC ]]
then
  echo "set MNENOMIC first, export MNENOMIC=\"your MNENOMIC\""
  exit
fi

for ((i=1;i<10000;i++))
do
	date
	echo "feed price for ${i} time"

	cp migrations_manual/102_setPrices.js migrations
	cp migrations_manual/103_getPrices.js migrations

	node getPrices.js

	truffle migrate --network bsctestnet --skip-dry-run -f 102
	truffle migrate --network bsctestnet --skip-dry-run -f 103

	rm -rf migrations/102_setPrices.js
	rm -rf migrations/103_getPrices.js

	sleep 1200
done