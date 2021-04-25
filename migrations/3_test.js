const fs = require('fs');
const Web3Utils = require('web3-utils');

const Synthx = artifacts.require("Synthx");
const Synth = artifacts.require("Synth");
const Stats = artifacts.require("Stats");
const SynthxDToken = artifacts.require("SynthxDToken");

module.exports = async function(deployer) {
    let contracts = {};
    let contractsAddrs = {};

    await fs.readFile('contractsAddrs.json', 'utf-8', (err, data) => {
        if (err) {
            throw err;
        }

        contractsAddrs = JSON.parse(data.toString());
        console.log(contractsAddrs.staker);
    });

    console.log(contractsAddrs);

    contracts.synthx = await Synthx.at(Synthx.address);
    contracts.dUSD = await Synth.at(contractsAddrs.dUSD);
    contracts.stats = await Stats.at(Stats.address);
    contracts.synthxDToken = await SynthxDToken.at(contractsAddrs.synthxDToken);
    contracts.dTSLA = await Synth.at(contractsAddrs.dTSLA);
    contracts.dAPPLE = await Synth.at(contractsAddrs.dAPPLE);

    console.log(contracts.synthx);
    console.log(contracts.dUSD);
    console.log(contracts.stats);
    console.log(contracts.synthxDToken);
    console.log(contracts.dTSLA);
    console.log(contracts.dAPPLE);

    console.log("-------- mint synths -------- ");
    let receipt = await contracts.synthx.mintFromCoin({value:Web3Utils.toWei('20', 'ether')});
    console.log('synthx.mintFromCoin receipt: ', receipt);

    bal = await contracts.dUSD.balanceOf(accounts[0]);
    console.log("dUSD balance:", Web3Utils.fromWei(bal, 'ether'));
    dTokenBal = await contracts.synthxDToken.balanceOf(accounts[0]);
    console.log("dToken balance:", Web3Utils.fromWei(dTokenBal, 'ether'));
    col = await contracts.stats.getTotalCollateral(accounts[0])
    console.log("totalDebt:", Web3Utils.fromWei(col.totalDebt, 'ether'));


    console.log("\n-------- burn synths -------- ");
    new Promise(r => setTimeout(r, 2000)); // sleep
    await contracts.synthx.burn(Web3Utils.fromAscii('ETH'), Web3Utils.toWei('2000', 'ether'));

    bal = await contracts.dUSD.balanceOf(accounts[0]);
    console.log("dUSD balance:", Web3Utils.fromWei(bal, 'ether'));
    dTokenBal = await contracts.synthxDToken.balanceOf(accounts[0]);
    console.log("dToken balance:", Web3Utils.fromWei(dTokenBal, 'ether'));
    col = await contracts.stats.getTotalCollateral(accounts[0])
    console.log("totalDebt:", Web3Utils.fromWei(col.totalDebt, 'ether'));

    res = await contracts.stats.getRewards(accounts[0]);
    console.log("rewards: ", Web3Utils.fromWei(res, 'ether'))

    res = await contracts.stats.getWithdrawable(accounts[0]);
    console.log("getWithdrawable:", Web3Utils.fromWei(res, 'ether'));

    console.log("-------- claim rewards -------- ");
    await contracts.synthx.claimReward();
    bal = await contracts.synthxToken.balanceOf(accounts[0]);
    console.log("synthx balance:", Web3Utils.fromWei(bal, 'ether'));

    console.log("-------- trade -------- ");
    ///////////////  trade
    // dUSD => dTSLA
    await contracts.synthx.trade(Web3Utils.fromAscii('dUSD'), Web3Utils.toWei('10000', 'ether'),  Web3Utils.fromAscii('dTSLA'));
    bal = await contracts.dTSLA.balanceOf(accounts[0]);
    console.log("dTSLA balance:", Web3Utils.fromWei(bal, 'ether'));

    // dTSLA => dAPPLE
    await contracts.synthx.trade(Web3Utils.fromAscii('dTSLA'), Web3Utils.toWei('13', 'ether'),  Web3Utils.fromAscii('dAPPLE'));
    bal = await contracts.dAPPLE.balanceOf(accounts[0]);
    console.log("dAPPLE balance:", Web3Utils.fromWei(bal, 'ether'));

    // get synth asset
    res = await contracts.stats.getAssets(Web3Utils.fromAscii('Synth'), accounts[0]);
    console.log("synth assets:", res)
    // get stake asset
    res = await contracts.stats.getAssets(Web3Utils.fromAscii('Stake'), accounts[0]);
    console.log("stake assets:", res)
    // get vaullts
    res = await contracts.stats.getVaults(accounts[0]);
    console.log("getVaults:", res)

    // getTotalCollateral
    res = await contracts.stats.getTotalCollateral(accounts[0]);
    console.log("getTotalCollateral:", res)
}
