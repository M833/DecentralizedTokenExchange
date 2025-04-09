const MyToken = artifacts.require("MyToken");
const DEX = artifacts.require("DEX");

module.exports = async function (deployer) {
    await deployer.deploy(MyToken, 1000000); // Deploy the token with an initial supply of 1,000,000
    const myTokenInstance = await MyToken.deployed();
    await deployer.deploy(DEX, myTokenInstance.address); // Deploy the DEX with the token address
};