const fs = require('fs');
const Web3Utils = require('web3-utils');

module.exports = async function(deployer) {

    let contracts = {};

    await fs.readFile('contracts.json', 'utf-8', (err, data) => {
        if (err) {
            throw err;
        }

        contracts = JSON.parse(data.toString());

        console.log(contracts.staker.address);
    });

    console.log("-------- mint synths -------- ");
    receipt = await contracts.synthx.mintFromCoin({value:Web3Utils.toWei('20', 'ether')});

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
