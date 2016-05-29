contract Conference { 

	bytes32 public topic;
	bytes32 public content;
	bytes32 public conferenceAddress;
	uint public amount;
	uint public maxNum;
	uint public beginTime;
	uint public endTime;		
	bytes32 public webSite;

	address public organizer;
	uint public joinNum;
	
	address private x = 0x0;

	mapping(address => User) private joinUsers;

	modifier onlyOwner()  {
	        if (msg.sender != organizer) throw;
	        _
	 }

	 modifier noMoney() {
	        if (msg.value < amount) throw;
	        _
	 }
	
	modifier noOverTime() {
	        if (now >= beginTime) throw;
	        _
	 }
	
	struct User {
		address userAddress;
		uint num ;
	}

	function Conference(bytes32 _topic, bytes32 _content, bytes32 _conferenceAddress, uint _amount, uint _maxNum, uint _beginTime, uint _endTime, bytes32 _webSite) {
		if (_maxNum <= 0 || _amount < 0)  throw;
		if (_beginTime < now || _endTime <= _beginTime) throw;
		topic = _topic;
		content = _content;
		conferenceAddress = _conferenceAddress;
		amount = _amount;
		maxNum = _maxNum;
		beginTime = _beginTime;
		endTime = _endTime;
		webSite = _webSite;
		organizer = msg.sender;
		joinNum = 0;
	}

	function buyTicket() noMoney  noOverTime public returns(bool success) {
		if (joinNum >= maxNum) {
			return false;
		}
		joinNum++;
		User u = joinUsers[msg.sender];
		if (u.userAddress == x) {  //not exist, add in mapping
			joinUsers[msg.sender] = User(msg.sender, 1);
		} else {
			u.num ++;
		}
		return true;
	}

	function refundTicket() noOverTime public returns(bool success) {
		address recipient = msg.sender;
		User u = joinUsers[recipient];
		if (u.userAddress != x) {
			address myAddress = this;
			uint refundAmount = amount * u.num;
			if (myAddress.balance >= refundAmount) {
				recipient.send(refundAmount);
				joinUsers[recipient] = User(x, 0);
				joinNum--;
				return true;
			}
		}
		return false;
	}

	function checkTicket(address recipient) onlyOwner public returns(bool success) {
	    	User u = joinUsers[recipient];
		if (u.userAddress != x) {
			joinUsers[recipient] = User(x, 0);
			return true;
		}
		return false;
	}

	function changeMaxNum(uint newMaxNum) onlyOwner public  returns(bool success) {		
		if (newMaxNum <= joinNum) {
			return false;
		}
		maxNum = newMaxNum;
		return true;
	}

	function finish()  onlyOwner {
		if (now < endTime) throw;
		if (this.balance > 0) {
			//send all balance to organizer 
			organizer.send(this.balance);
		}
	}
	
	function destroy()  onlyOwner {
		if (now < endTime) throw;
		suicide(organizer);
	}


}




