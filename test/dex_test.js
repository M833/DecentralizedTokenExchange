const MyToken = artifacts.require("MyToken");
const DEX = artifacts.require("DEX");

contract("DEX", (accounts) => {
    let myTokenInstance, dexInstance;

    before(async () => {
        myTokenInstance = await MyToken.new(1000000); // Initial supply of 1,000,000 tokens
        dexInstance = await DEX.new(myTokenInstance.address);
        await myTokenInstance.transfer(accounts[1], 1000); // Transfer tokens to account[1]
    });

    it("should allow adding liquidity", async () => {
        await myTokenInstance.approve(dexInstance.address, 100, { from: accounts[1] });
        await dexInstance.addLiquidity(100, { from: accounts[1], value: 100 });
        const liquidityBalance = await dexInstance.liquidity(accounts[1]);
        assert.equal(liquidityBalance, 100, "Liquidity was not added correctly");
    });

    it("should allow swapping ETH for tokens", async () => {
        const initialBalance = await myTokenInstance.balanceOf(accounts[0]);
        await dexInstance.swapEthForTokens({ from: accounts[0], value: 50 });
        const finalBalance = await myTokenInstance.balanceOf(accounts[0]);
        assert(finalBalance > initialBalance, "Tokens were not swapped correctly");
    });
});