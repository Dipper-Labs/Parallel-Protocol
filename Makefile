all:
	truffle compile

compile:
	truffle compile

migrate:
	truffle migrate --network ganache 

clean:
	rm -rf build

resetmigrate:
	truffle migrate --reset --network ganache
