// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

contract SmartWallet {
    address public owner;
    mapping (address => uint) balanceRecived;
    mapping(address => uint) public allowance;
    uint public ownerChangeLimit = 3;
    uint public ownerChangeCount;

    constructor() {
        owner = msg.sender;        
    }

    event AllowanceChanged(address indexed _forWho, address indexed _byWhom, uint _oldAmount, uint _newAmount);
    event MoneySent(address indexed _beneficiary, uint _amount, address indexed _sender);

    function sendMoney () external  payable {
        require(msg.value >= 1 ether, "The transaction is less than a minimum amount.");
        balanceRecived[msg.sender] += msg.value;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "you are not an owner!");
        _;
    }

    function trade(address payable _to, uint _value) public onlyOwner {
        require(_value <= address(this).balance, "Not enough balance.");
        _to.transfer(_value);
        balanceRecived[_to] += _value;
    }

    function setOwner(address payable _newOwner) public onlyOwner {
        require(tx.origin == owner, "Not your contract");
        require(ownerChangeCount < ownerChangeLimit, "Owner change limit reached");
        owner = _newOwner;
        ++ownerChangeCount;
    }

    function getBalance () public view returns (uint) {
       return address(this).balance;
    }
    
    function getTransaction(address _from, uint _value) public view returns (bool) {
        return (_from == owner) && (balanceRecived[_from] >= _value);
    }

    function setAllowance(address _who, uint _amount) public onlyOwner {
        emit AllowanceChanged(_who, msg.sender, allowance[_who], _amount);
        allowance[_who] = _amount;
    }

    
    function spend(address payable _recipient, uint _amount) public {
        require(allowance[msg.sender] >= _amount, "You are not allowed to spend this amount");
        allowance[msg.sender] -= _amount;
        _recipient.transfer(_amount);
        emit MoneySent(_recipient, _amount, msg.sender);
    }

}
