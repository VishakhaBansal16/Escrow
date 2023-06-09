//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Escrow {
    enum EscrowStatus { InProgress, Completed, Disputed }

    struct Transaction {
        address payable buyer; // Address of the buyer
        address payable seller; // Address of the seller
        address arbitrator; // Address of the arbitrator
        uint256 amount; // Amount of funds held in escrow
        EscrowStatus status; // Current status of the escrow
        bool buyerApproved; // Flag indicating whether the buyer has approved the release of funds
        bool sellerApproved; // Flag indicating whether the seller has approved the release of funds
    }

    mapping(uint256 => Transaction) public transactions; // Mapping of transaction ID to Transaction struct
    uint256 public transactionCount; // Counter for tracking the number of transactions

    event EscrowCreated(uint256 indexed transactionId, address buyer, address seller, uint256 amount); // Event emitted when a new escrow is created
    event FundsDeposited(uint256 indexed transactionId, address depositor, uint256 amount); // Event emitted when funds are deposited into the escrow
    event FundsReleased(uint256 indexed transactionId, address receiver, uint256 amount); // Event emitted when funds are released from the escrow
    event DisputeRaised(uint256 indexed transactionId); // Event emitted when a dispute is raised
    event DisputeResolved(uint256 indexed transactionId, address arbitrator, address winner, uint256 amount); // Event emitted when a dispute is resolved

    modifier onlyBuyer(uint256 transactionId) {
        require(msg.sender == transactions[transactionId].buyer, "Only the buyer can perform this action");
        _;
    }

    modifier onlySeller(uint256 transactionId) {
        require(msg.sender == transactions[transactionId].seller, "Only the seller can perform this action");
        _;
    }

    modifier onlyArbitrator(uint256 transactionId) {
        require(msg.sender == transactions[transactionId].arbitrator, "Only the arbitrator can perform this action");
        _;
    }

    // Function to create a new escrow
    function createEscrow(address payable _seller, address _arbitrator) external payable {
        require(msg.value > 0, "Amount must be greater than zero");
        
        transactionCount++;
        transactions[transactionCount] = Transaction({
            buyer: payable(msg.sender),
            seller: _seller,
            arbitrator: _arbitrator,
            amount: msg.value,
            status: EscrowStatus.InProgress,
            buyerApproved: false,
            sellerApproved: false
        });

        emit EscrowCreated(transactionCount, msg.sender, _seller, msg.value);
    }

    // Function to deposit funds into an existing escrow
    function depositFunds(uint256 transactionId) external payable {
        require(transactions[transactionId].status == EscrowStatus.InProgress, "Escrow is not in progress");
        require(msg.value > 0, "Amount must be greater than zero");
        
        transactions[transactionId].amount += msg.value;

        emit FundsDeposited(transactionId, msg.sender, msg.value);
    }

    // Function to release funds from an escrow to the seller
    function releaseFunds(uint256 transactionId) external onlySeller(transactionId) {
        require(transactions[transactionId].status == EscrowStatus.InProgress, "Escrow is not in progress");
        require(transactions[transactionId].sellerApproved == true, "Seller has not approved the release yet");

        transactions[transactionId].status = EscrowStatus.Completed;
        transactions[transactionId].seller.transfer(transactions[transactionId].amount);

        emit FundsReleased(transactionId, transactions[transactionId].seller, transactions[transactionId].amount);
    }

    // Function to initiate a dispute for an escrow
    function initiateDispute(uint256 transactionId) external onlyBuyer(transactionId) {
        require(transactions[transactionId].status == EscrowStatus.InProgress, "Escrow is not in progress");

        transactions[transactionId].status = EscrowStatus.Disputed;

        emit DisputeRaised(transactionId);
    }

    // Function to resolve a dispute for an escrow
    function resolveDispute(uint256 transactionId, address payable winner) external onlyArbitrator(transactionId) {
        require(transactions[transactionId].status == EscrowStatus.Disputed, "Escrow is not disputed");

        transactions[transactionId].status = EscrowStatus.Completed;
        winner.transfer(transactions[transactionId].amount);

        emit DisputeResolved(transactionId, msg.sender, winner, transactions[transactionId].amount);
    }

    // Function for the buyer or seller to approve the release of funds
    function approveRelease(uint256 transactionId) external {
        require(transactions[transactionId].status == EscrowStatus.InProgress, "Escrow is not in progress");
        
        if (msg.sender == transactions[transactionId].buyer) {
            transactions[transactionId].buyerApproved = true;
        } else if (msg.sender == transactions[transactionId].seller) {
            transactions[transactionId].sellerApproved = true;
        }
        
        if (transactions[transactionId].buyerApproved && transactions[transactionId].sellerApproved) {
            transactions[transactionId].status = EscrowStatus.Completed;
            transactions[transactionId].seller.transfer(transactions[transactionId].amount);
            
            emit FundsReleased(transactionId, transactions[transactionId].seller, transactions[transactionId].amount);
        }
    }
}
