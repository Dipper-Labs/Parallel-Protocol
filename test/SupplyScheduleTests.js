const SupplySchedule = artifacts.require("SupplySchedule");

contract("SupplySchedule", accounts => {
    it("currentPeriod should be 0", () =>
        SupplySchedule.deployed()
            .then(instance => instance.currentPeriod.call())
            .then(currentPeriod => {
                assert.equal(
                    currentPeriod.toString(),
                    "0",
                    "currentPeriod != 0"
                );
            }));
});