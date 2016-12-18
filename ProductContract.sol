pragma solidity ^0.4.7;
contract ProductContract { // can be killed, so the owner gets sent the money in the end

	struct User {
		address userAddress;
		uint startTime;
	}
	
	struct Product {
		bytes32 name;
    	bytes32 webSite;

    	uint amount; //price
    	uint maxNum;
    	uint yearRate;

    	uint beginTime;
    	uint endTime;	
    	
    	address organizer;
	    uint buyNum;
	}
	
	address x = 0x0;
	Product public product;
	mapping(address => User) public joinUsers;

	event log(address _from, uint _amount,  uint _now,  uint _balance, bytes32 _desc); // so you can log the event

	modifier onlyOwner()  {
	        if (msg.sender != product.organizer) throw;
	        _;
	 }

	 modifier noMoney() {
	        if (msg.value < product.amount) throw;
	        _;
	 }
	 

	function ProductContract(bytes32 _name, uint _amount, uint _maxNum, uint _yearRatePercent, uint _beginTime, uint _endTime, bytes32 _webSite) {
		if (_maxNum <= 0 || _amount < 0)  throw;
		if (_endTime <= _beginTime) throw;
		product = Product(_name,
    		_webSite, 
    		_amount,
    		_maxNum,
    		_yearRatePercent / 100,
    		_beginTime,
    		_endTime,
    		msg.sender,
    		0);
	}

	function buy() noMoney public returns(bool success) { 
		if (product.buyNum >= product.maxNum) {
			return false;
		}
		if (now >= product.endTime) {
			return false;
		}
	    log(msg.sender, msg.value, now, product.organizer.balance, "buy begin");
		joinUsers[msg.sender] = User(msg.sender, now);
		product.buyNum ++;
		if(!msg.sender.send(product.amount)) {
		    throw;
		}
		log(msg.sender, msg.value, now, product.organizer.balance,  "buy end");
		return true;
	}

	function sell() public returns(bool success) {
		User user = joinUsers[msg.sender];
		if (user.userAddress != x) {
			if (now >= product.endTime) throw;
			address myAddress = this;
			uint totalAmount = getTotalIncome();
			if (myAddress.balance >= totalAmount) {
				log(user.userAddress, totalAmount, now, product.organizer.balance,  "sell begin");
				if (!user.userAddress.send(totalAmount)) {
				    throw;
				}
				log(user.userAddress, totalAmount, now, product.organizer.balance,  "sell end");
				joinUsers[user.userAddress] = User(x, now);
				product.buyNum--;
				return true;
			}
		}
		return false;
	}

	function getTotalIncome() public returns(uint income) {
	    User u = joinUsers[msg.sender];
		if (u.userAddress != x) {
		    // one year
			uint totalYear = (now - product.endTime) / 31536000000;
			if (totalYear <= 0) {
			    totalYear = 1;
			}
			uint totalAmount = product.amount * (1 + product.yearRate * totalYear);
			return totalAmount;
		}
		return 0;
	}

	function getLeftNum() public returns(uint num) {
	    User u = joinUsers[msg.sender];
		if (u.userAddress != x) {
			return product.maxNum - product.joinNum;
		}
		return 0;
	}
	

	function destroy() onlyOwner {
		suicide(product.organizer);
	}
	
	function() { throw; }


}




