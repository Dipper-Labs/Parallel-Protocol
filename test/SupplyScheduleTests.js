const SupplySchedule = artifacts.require("SupplySchedule");

contract("SupplySchedule", () => {
    it("currentPeriod should be 0", () =>
        SupplySchedule.deployed()
            .then(instance => instance.currentPeriod.call())
            .then(currentPeriod => {
                assert.equal(
                    currentPeriod.toString(),
                    "0",
                    "currentPeriod != 0"
                );
            })
    );

    it("period supply test 1", async () => {
        let period0;
        let period200;
        let period364;

        const instance = await SupplySchedule.deployed();
        await instance.periodSupply.call(0)
            .then(p0 => {
                period0 = p0.toString();
                return instance.periodSupply.call(200)
            })
            .then(p200 => {
                period200 = p200.toString();
                return instance.periodSupply.call(364)
            })
            .then(p364 => {
                period364 = p364.toString();
            });

        assert.equal(
            period0,
            period200,
            "period0 not equal period200"
        );

        assert.equal(
            period200,
            period364,
            "period200 not equal period364"
        );
    })

    it("period supply test 2", async () => {
        let period0;    // year 1
        let period365;  // year 2
        let period730;  // year 3
        let period1095; // year 4
        let period1460; // year 5
        let period1825; // year 6
        let period2190; // year 7
        let period3000; // year x

        const instance = await SupplySchedule.deployed();
        await instance.periodSupply.call(0)
            .then(p0 => {
                period0 = p0;
                return instance.periodSupply.call(365)
            })
            .then(p365 => {
                period365 = p365;
                return instance.periodSupply.call(730)
            })
            .then(p730 => {
                period730 = p730;
                return instance.periodSupply.call(1095)
            })
            .then(p1095 => {
                period1095 = p1095;
                return instance.periodSupply.call(1460)
            })
            .then(p1460 => {
                period1460 = p1460;
                return instance.periodSupply.call(1825)
            })
            .then(p1825 => {
                period1825 = p1825;
                return instance.periodSupply.call(2190)
            })
            .then(p2190 => {
                period2190 = p2190;
                return instance.periodSupply.call(3000)
            })
            .then(p3000 => {
                period3000 = p3000;
            });

        assert.equal(
            period0 / 2,
            period365,
            "period365 != (period0/2)"
        );

        assert.equal(
            period365 / 2,
            period730,
            "period730 != (period365/2)"
        );

        assert.equal(
            period730 / 2,
            period1095,
            "period1095 != (period730/2)"
        );

        assert.equal(
            period1095 / 2,
            period1460,
            "period1460 != (period1095/2)"
        );

        assert.equal(
            period1460 / 2,
            period1825,
            "period1825 != (period1460/2)"
        );

        assert.equal(
            period1825 / 1,
            period2190 / 1,
            "period1825: " + period1825.toString() + " != period2190: " + period2190.toString()
        );

        assert.equal(
            period2190 / 1,
            period3000 / 1,
            period2190.toString() + " != " + period3000.toString()
        );
    })
});
