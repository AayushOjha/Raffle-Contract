const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const { network, ethers } = require("hardhat");
const {
  networkConfig,
  developmentChains,
} = require("../../utils/hardhat-config-helper");

module.exports = buildModule("TestV5Module", (m) => {
  const chainId = network.config.chainId;

  if (developmentChains.includes(chainId)) {
    console.log(
      "This contract uses chainLink so can not be deployed on local node"
    );
    console.log("need to deploy moke contract to make this work in local node");
  } else {
    // constructor arguments
    const vrfCoordinatorV2 = networkConfig[chainId].vrfCoordinator;
    const entryFee = hre.ethers.parseEther("0.001");
    const subscriptionId = process.env.VRF_SUB_ID;
    const gasLane = networkConfig[chainId].keyHash;
    const callbackGasLimit = 9000000;

    const Raffle = m.contract("Raffle", [vrfCoordinatorV2, entryFee, subscriptionId, gasLane, callbackGasLimit]);

    return { Raffle };
  }
});
