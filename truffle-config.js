const HDWalletProvider = require("truffle-hdwallet-provider");

module.exports = {
  networks: {
    ganache: {
     host: "127.0.0.1",
     port: 7545,
     network_id: "*",
    },
    local: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
    },
    ropsten: {
      provider: () => new HDWalletProvider(process.env.MNENOMIC, "https://ropsten.infura.io/v3/" + process.env.INFURA_API_KEY),
      network_id: 3,
      gas: 9000000,
      gasPrice: 10000000000
    },
    bsc: {
      provider: () => new HDWalletProvider(process.env.MNENOMIC, "https://data-seed-prebsc-1-s1.binance.org:8545/"),
      network_id: "*",
      gas: 9000000,
      gasPrice: 10000000000
    },
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  compilers: {
    solc: {
      version: "0.5.17",
      settings: {
        optimizer: {
          enabled: true,
          runs: 2
        },
        evmVersion: "istanbul"
      }
    }
  }
};
