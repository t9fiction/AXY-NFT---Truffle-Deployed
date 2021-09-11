const AXY721 = artifacts.require("AXY721");

module.exports = async function (deployer,network,accounts) {
  await deployer.deploy(AXY721);
};
