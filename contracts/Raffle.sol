// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// imports
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";

// errors
error Raffle__LessThanEntryFee();

contract Raffle is VRFConsumerBaseV2, ConfirmedOwner {
    // State variables
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint256 private immutable i_entry_fee;
    address payable[] private s_participants;
    uint64 private immutable i_subscription_id;
    bytes32 private immutable i_gas_lane;
    uint32 private immutable i_callback_gas_limit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }
    //TODO: make it private
    mapping(uint256 => RequestStatus) public s_requests;

    // events
    event RaffleEnter(address indexed participant);

    // constructor
    constructor(
        address vrfCoordinatorV2,
        uint256 entryFee,
        uint64 subscriptionId,
        bytes32 gasLane,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinatorV2) ConfirmedOwner(msg.sender) {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_entry_fee = entryFee;
        i_subscription_id = subscriptionId;
        i_gas_lane = gasLane;
        i_callback_gas_limit = callbackGasLimit;
    }

    // core functions
    function enterRaffle() public payable {
        if (msg.value < i_entry_fee) {
            revert Raffle__LessThanEntryFee();
        }

        s_participants.push(payable(msg.sender));
        emit RaffleEnter(msg.sender);
    }

    // getters
    function getEntryFee() public view returns (uint256) {
        return i_entry_fee;
    }

    function getParticipant(uint256 index) public view returns (address) {
        return s_participants[index];
    }

    // temp testing

    function requestRandomWords()
        external
        onlyOwner
        returns (uint256 requestId)
    {
        // Will revert if subscription is not set and funded.
        requestId = i_vrfCoordinator.requestRandomWords(
            i_gas_lane,
            i_subscription_id,
            REQUEST_CONFIRMATIONS,
            i_callback_gas_limit,
            NUM_WORDS
        );
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
    }
}
