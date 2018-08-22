pragma solidity ^0.4.21;

/*
Simple escrow contract that mediates disputes using a burn contract
*/
contract Escrow {

    enum State {UNINITIATED, AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE}
    State public currentState;

    modifier inState(State expectedState) { require(currentState == expectedState); _; }
    modifier buyerOnly() { require(msg.sender == buyer); _; }
    modifier correctPrice() { require(msg.value == price); _; }

    address public buyer;
    address public seller;

    bool public buyer_in;
    bool public seller_in;

    uint public price;

    function Escrow(address _buyer, address _seller, uint _price){
        buyer = _buyer;
        seller = _seller;
        price = _price * (10 ** 18);
    }

    function initiateContract() correctPrice inState(State.UNINITIATED) payable {
        if (msg.sender == buyer) {
            buyer_in = true;
        }
        if (msg.sender == seller) {
            seller_in = true;
        }
        if (buyer_in && seller_in) {
            currentState = State.AWAITING_PAYMENT;
        }
    }

    function confirmPayment() buyerOnly correctPrice inState(State.AWAITING_PAYMENT) payable {
        currentState = State.AWAITING_DELIVERY;
    }

    function confirmDelivery() buyerOnly inState(State.AWAITING_DELIVERY) {
        buyer.call.value(price)();
        seller.call.value(price  * 2)();
        currentState = State.COMPLETE;
    }
    
    function load() public payable {
        // utility method to battle Remix limitations
    }
    
    function getBalance() public view returns(uint256) {
        // utility method to battle Remix limitations
        return address(this).balance;
    }
}

contract Proxy {
    
    address public owner;

    constructor() public {
        owner = msg.sender;
    }
    
    function callInitiateContract(address _address) public payable {
        Escrow(_address).initiateContract.value(msg.value)();
    }
    
    function callConfirmPayment(address _address) public payable {
        Escrow(_address).confirmPayment.value(msg.value)();
    }
    
    function callConfirmDelivery(address _address) public {
        Escrow(_address).confirmDelivery();
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function withdraw() public {
        require(msg.sender == owner);
        msg.sender.send(getBalance());
    }
    
    function () public payable {
        callConfirmDelivery(msg.sender);
    }
    
}
