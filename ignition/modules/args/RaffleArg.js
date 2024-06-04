const { networkConfig } = require("../../../utils/hardhat-config-helper");

const vrfCoordinatorV2 = networkConfig[11155111].vrfCoordinator;
const entryFee = hre.ethers.parseEther("0.0001");
const subscriptionId = process.env.VRF_SUB_ID;
const gasLane = networkConfig[11155111].keyHash;
const callbackGasLimit = 900000;

const RaffleSepoliaArgs = [vrfCoordinatorV2, entryFee, subscriptionId, gasLane, callbackGasLimit]
module.exports = RaffleSepoliaArgs