// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20v1.sol";

contract SupplyChain is IERC20v1 {
    
  constructor(){
      
  }
    
    struct OrderStatus { 
        string trackingNumber;
        string parcelStatus;
    }
    
    struct UserOrder { 
        uint256 orderId;
    }
    
    uint256 [] private userOrders;
    
     mapping (address => UserOrder[] ) private userOrder;
     mapping(address => mapping( uint256 => OrderStatus)) private orders;
     mapping(address=>uint256) private _balances;
     mapping(address => mapping(address => uint256)) private _allowances;
    
    // Add new Order
    function newOrders(uint256 orderId, address buyer ,string memory trackingNumber, string memory parcelStatus ) public returns (bool) {
        orders[buyer][orderId] = OrderStatus(trackingNumber, parcelStatus);
        userOrder[buyer].push(UserOrder(orderId));
       
        return true;
    }
    
    //update order status
    function updateOrderStatus(uint256 _orderId, address _buyer,string memory _parcelStatus ) public returns (bool) {
        orders[_buyer][_orderId].parcelStatus = _parcelStatus;
        return true;
    }
    
    
    //get the status of a specific order
    function orderStatusOf(address _buyer, uint256 _orderId) public view returns ( string memory, string memory ){
        return ( 
            orders[_buyer][_orderId].trackingNumber, 
            orders[_buyer][_orderId].parcelStatus 
        );
    }
    
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
    
}