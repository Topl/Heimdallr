pragma solidity 0.4.24;


import "./SafeMath.sol";


contract Heimdall {

    using SafeMath for uint256; // no overflows

    mapping(address=>uint256) public withdrawals;
    address public owner;
    uint256 public ownerBalance = 0;
    uint256 public depositFee = 0;
    uint256 public withdrawalFee = 0;
    bool public contractOpen = false;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier reqOpen() {
        require(contractOpen);
        _;
    }

    function Deposit(string memory _toplAdrs) public payable reqOpen {
        assert(msg.value.sub(depositFee) > 0); // no debt
        ownerBalance = ownerBalance.add(depositFee);
        emit deposit_event(owner, msg.sender, msg.value, depositFee, _toplAdrs);
    }

    function StartWithdrawal(uint256 _amount) public reqOpen {
        assert(_amount.sub(withdrawalFee) > 0); // no debt
        withdrawals[msg.sender] = _amount;
        emit startedWithdrawal_event(owner, msg.sender, _amount, withdrawalFee);
    }

    function ApproveWithdrawal(
        address _ethAdrs,
        uint256 _amount,
        uint256 _withdrawalFee
    ) public onlyOwner {
        withdrawals[_ethAdrs] = 0;
        ownerBalance = ownerBalance.add(_withdrawalFee);
        _ethAdrs.transfer(_amount.sub(_withdrawalFee));
        emit approvedWithdrawal_event(owner, _ethAdrs, _amount, _withdrawalFee);
    }

    function DenyWithdrawal(address _ethAdrs, uint256 _amount) public onlyOwner {
        withdrawals[_ethAdrs] = 0;
        emit deniedWithdrawal_event(owner, _ethAdrs, _amount, _withdrawalFee);
    }

    function SetDepositFee(uint256 _fee) public onlyOwner {
        depositFee = _fee;
        emit depositFeeSet_event(owner, oldFee, _fee);
    }

    function SetWithdrawalFee(uint256 _fee) public onlyOwner {
        withdrawalFee = _fee;
        emit withdrawalFeeSet_event(owner, oldFee, _fee);
    }

    function OwnerWithdrawal() public onlyOwner {
        emit OwnerWithdrawalEvent(owner, ownerBalance);
        ownerBalance = 0;
        owner.transfer(ownerBalance);
    }

    function ToggleContractOpen() public onlyOwner {
        contractOpen = !contractOpen;
        emit ToggleContractOpenEvent(owner, !contractOpen, contractOpen);
    }

    event DepositEvent(
        address ownerAddress,
        address depositerAddress,
        uint256 deposit,
        uint256 depositFee,
        string toplAdrs);

    event StartWithdrawalEvent(
        address ownerAddress,
        address withdrawerAddress,
        uint256 withdrawalAmount,
        uint withdrawalFee);

    event ApproveWithdrawalEvent(
        address ownerAddress,
        address withdrawerAddress,
        uint256 withdrawalAmount,
        uint256 withdrawalFee);

    event DeniedWithdrawalEvent(
        address ownerAddress,
        address withdrawerAddress,
        uint256 withdrawalAmount,
        uint256 withdrawalFee);

    event SetDepositFeeEvent(address ownerAddress, uint256 oldFee, uint256 newFee);
    event SetWithdrawalFeeEvent(address ownerAddress, uint256 oldFee, uint256 newFee);
    event OwnerWithdrawalEvent(address ownerAddress, uint256 withdrawalAmount);
    event ToggleContractOpenEvent(address ownerAddress, bool oldContractOpen, bool newContractOpen);
}
