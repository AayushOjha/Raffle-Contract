// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// imports
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

// errors
error Raffle__LessThanEntryFee();

contract Raffle is VRFConsumerBaseV2Plus {
    // State variables
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
    //? do i need them?
    uint256[] public requestIds;
    uint256 public lastRequestId;
    mapping(uint256 => RequestStatus)
        public s_requests; /* requestId --> requestStatus */

    // events
    event RaffleEnter(address indexed participant);

    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    // constructor
    constructor(
        address vrfCoordinatorV2,
        uint256 entryFee,
        uint64 subscriptionId,
        bytes32 gasLane,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinatorV2) {
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
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_gas_lane,
                subId: i_subscription_id,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: 100000,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );

        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, NUM_WORDS);

        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] calldata _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords);
    }

    function getRequestStatus(
        uint256 _requestId
    ) public view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }
}
