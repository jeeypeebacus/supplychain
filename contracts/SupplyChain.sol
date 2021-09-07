// SPDX-License-Identifier: MIT

// pragma solidity ^0.8.0
pragma solidity ^0.8.3;

import "./IERC20v1.sol";

contract SupplyChain is IERC20v1 {
    
  constructor(){
      
  }
    
    struct OrderStatus { 
        string trackingNumber;
        // string parcelStatus;
        State status;
    }
    
    struct OrderHistory {
        string trackingNumber;
        State status;
        uint256 transactionDate;
    }
    
    
    enum State { 
        ToPack,
        Shipped,
        Delivered
    }
    
    State private state;
    
     mapping(address => mapping( uint256 => OrderStatus)) private orders;
     mapping(address=>uint256) private _balances;
     mapping(address => mapping(address => uint256)) private _allowances;
     mapping(address => mapping( uint256 => OrderHistory[])) private orderHistory;
     
     
    //==========================
    // Tracking Functions 
    //==========================
    
    // Add new Order
    function newOrders(uint256 orderId, address buyer ,string memory trackingNumber, string memory parcelStatus, uint256 transactionDate  ) public returns (bool) {
        
        require(buyer != address(0), 'Invalid Buyer Address.');
        
        
        State tmpStatus;
         
        if( keccak256(bytes(parcelStatus)) == keccak256(bytes('To Pack')) ) {
            tmpStatus = State.ToPack;
        }else{
            revert("Invalid state value.");
        }
        
        orders[buyer][orderId] = OrderStatus(trackingNumber, tmpStatus);
        orderHistory[buyer][orderId].push(OrderHistory(trackingNumber, tmpStatus, transactionDate));
        
        //Emit when there is new order
        emit NewOrders( orderId, buyer, trackingNumber, parcelStatus);
       
        return true;
    }
    
    
    //update order status
    function updateOrderStatus(uint256 _orderId, address _buyer,string memory _parcelStatus, string memory _trackingNumber, uint256 _transactionDate ) public returns (bool) {
        
        require(_buyer != address(0), 'Invalid Buyer Address.' );
        
        State tmpStatus;
        
        if( keccak256(bytes(_parcelStatus)) == keccak256(bytes('To Pack')) ) {
            tmpStatus = State.ToPack;
        }else if( keccak256(bytes(_parcelStatus)) == keccak256(bytes('Shipped')) ) {
            tmpStatus = State.Shipped;
        }else if( keccak256(bytes(_parcelStatus)) == keccak256(bytes('Delivered')) ) {
            tmpStatus = State.Delivered;
        }else{
            revert("Invalid state value.");
        }
        
        orders[_buyer][_orderId].status = tmpStatus;
        orderHistory[_buyer][_orderId].push(OrderHistory(_trackingNumber, tmpStatus, _transactionDate));
        
        // Emit when there the status is modefied.
        emit UpdateOrderStatus(_orderId, _buyer, _parcelStatus, _transactionDate);
        
        return true;
    }
    
    
    //get the status of a specific order
    function orderStatusOf(address _buyer, uint256 _orderId) public view returns ( string memory, State ){
        
        require(_buyer != address(0), 'Invalid Buyer Address.' );
        
        return ( 
            orders[_buyer][_orderId].trackingNumber, 
            orders[_buyer][_orderId].status 
        );
    }
    
    
    function getOrderStatusHistory(uint256 _orderId, address buyer) public view returns ( OrderHistory[] memory) {
        return  (orderHistory[buyer][_orderId])  ;
    }
    
    
    //==========================
    // End Tracking Functions 
    //==========================
    
    
    
    //==========================
    // Micropayment Functions 
    //==========================
    
    //get balance of the account
    function balanceOf(address account) public view override returns (uint256){
         // should return balance of an account
         return _balances[account];
     }
     
     // allowed allowance to widraw by the user
     function allowance(address owner, address spender) public view override returns (uint256){
         // Should return allowance of spender on behafl of owner
         return _allowances[owner][spender];
     }
     
      function transfer(address recipient, uint256 amount) public override returns (bool){
         /* Place validation
         1. Check if recipient address is not 0
         2. Check balance if sufficient
         3. update balance
         4. emit transfer
         */
         
         require( recipient != address(0), 'Invalid transfer to zero' );
         require(_balances[msg.sender] >= amount, 'Insufficient Balance');
         
         //update spender Balance
         //update recipient Balance
         _balances[msg.sender] -= amount;
         _balances[recipient] += amount;
         
         emit Transfer( msg.sender, recipient, amount );
         
         return true;
         
     }
     
     
     function approve(address spender, uint256 amount) public override returns (bool){
         
         require( spender != address(0), 'Invalid transfer to zero' );
         
         _allowances[msg.sender][spender] = amount;
         
         emit Approval( msg.sender, spender, amount );
         
         return true;
         
     }
     
     
     function transferFrom( address sender, address recipient, uint256 amount ) public override returns (bool) {
         
         
         require(sender != address(0), 'Invalid transfer from address zero' );
         require(recipient != address(0), 'Invalid transfer to address zero' );
         require(_allowances[sender][msg.sender] >= amount, 'Insufficient Balance' );
          
         _balances[sender] -= amount;
         _balances[recipient] += amount;
         
         uint256 updatedAllowance = _allowances[sender][msg.sender] - amount;
         _allowances[sender][msg.sender] = updatedAllowance;
         
        //  emit Transfer(sender, recipient, amount);
         emit Approval(sender, msg.sender, amount);
         
         return true;
         
     }
     
    //==============================
    // End Micropayment Functions 
    //==============================
    
}