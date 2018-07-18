pragma solidity ^0.4.24;


contract Betting {
	address  organization;
	address  owner;
	address jackpot;
	uint32 idmatch;
	uint256 stoptime;
	uint256 [3] gamebalance;
	address[] add1;
	address[] add2;
	address[] add3;
	uint256[] lot1;
	uint256[] lot2;
	uint256[] lot3;
	uint256 maxbet;
	uint256  minbet;
	
	event add_match( uint32 _idmatch,uint256 _stoptime);
	event end_match(uint32 _idmatch, uint32 _result);
	event new_bet( address sender,uint32 _idmatch, uint32 _bettype, uint256 _value);
	event transfer_jackpot(address organization,uint256 value);
	event transfer_organization(address organization,uint256 value);
	event transfer_winner(address sender,uint256 value);
	event refund(address sender,uint256 value);
	event test(address sender,uint256 _num1,uint256 _num2,uint256 _num3);
	constructor() public {
		owner = msg.sender;
		maxbet = 1e18;
		minbet = 1e16;
		organization = 0x4ce58711a458f24ec50d005ba1edc71a114f76f5;
		jackpot = 0x6d8d102c944a8933432e3f9d0b87749a66e54404;
		
	}
	function addmatch(uint32 _idmatch,  uint256 _stoptime) public returns (bool) {
	
		if(msg.sender == owner)
		{
			
				if(idmatch == 0)
				{
					idmatch = _idmatch;
					stoptime = _stoptime;
					emit add_match( _idmatch,_stoptime);
					return true;
				}
				
					
		}
		return false;
	}
	function endmatch(uint32 _idmatch, uint32 _resultend) public returns (bool){
		
		if(msg.sender == owner)
		{
			if(idmatch == _idmatch)
				{
					
					
					findwinner(_idmatch,_resultend);
					emit end_match( _idmatch,_resultend);
					return true;
				}
				
			
		}	
		return false;		
	}

	function kill() public {
      if(msg.sender == owner) selfdestruct(owner);
	}
	function() public payable {}
	
	function getIdmatch() public view returns (uint32) {
		
		return idmatch;
		
	}
	
	function bet1(uint32 _res, uint32 _idmatch) public payable returns (bool)
	{
		if( msg.value >= minbet && msg.value <= maxbet &&idmatch == _idmatch  && now < stoptime)
		{
		
				
					
						gamebalance[0] += msg.value;
					
						lot1.push(_res + msg.value);
						add1.push(msg.sender);
						emit new_bet( msg.sender,_idmatch, 1, msg.value);
					
		}				
			
		else
		{
			emit refund(msg.sender,msg.value);
			msg.sender.transfer(msg.value);
		}
     
   }
	function bet2(uint32 _res, uint32 _idmatch) public payable returns (bool)
	{
		if( msg.value >= minbet && msg.value <= maxbet  &&idmatch == _idmatch  && now < stoptime)
		{
			
					
						gamebalance[1] += msg.value;
						add2.push(msg.sender);
						lot2.push(_res + msg.value);
						emit new_bet( msg.sender,_idmatch,2, msg.value);
					
		}				
			
		else
		{
			emit refund(msg.sender,msg.value);
			msg.sender.transfer(msg.value);
		}
     
    }
	function bet3(uint32 _res, uint32 _idmatch) public payable returns (bool)
	{
		if( msg.value >= minbet && msg.value <= maxbet  &&idmatch == _idmatch  && now < stoptime)
		{
			
						gamebalance[2] += msg.value;
						add3.push(msg.sender);
						lot3.push(_res + msg.value);
						emit new_bet( msg.sender,_idmatch, 3, msg.value);
					
		}				
			
		else
		{
			emit refund(msg.sender,msg.value);
			msg.sender.transfer(msg.value);
		}
     
    }
	
   function findwinner(uint32 _idmatch, uint32 _result) public returns (bool)
   {
	   uint32 i;
	   uint256 sum = 0;
	   uint256 award ;
	   uint32 a;
	   uint32  b;
	   uint32 kq = 0;
	   uint256 total = address(this).balance;
	   uint256 temp;
	   //check first match
	   if(idmatch == _idmatch)
	   {
		   //check first result game
		   b = _result%100;
		   a = (_result - b) / 100;
		   if( a > b)
			   kq = 3; //first win
		   else
			   if( a == b)
				   kq = 2; //equal
			   else
				   kq = 1;//lost
		   for( i = 0; i< lot1.length; i++)
		   {
			   
			   if(lot1[i]%1e4 == kq)
			   {
				   sum = sum + (lot1[i] - (lot1[i]%1e4)) ; //sum of people win
			   }
			   
		   }
		   if( sum > 0)
		   {
			   award = (((gamebalance[0]*92)/100)); //award foreach eth
				for( i = 0; i< lot1.length; i++)
			   {  
					if(lot1[i]%1e14 == kq)
					{
						temp = award*((lot1[i] - (lot1[i]%1e4))/sum);
						add1[i].transfer(temp); //increase balance of winners
						emit transfer_winner(add1[i], temp);
						total = total - temp;
					}
				   
			   }
			  
			  
			   sum = 0;
		   }
		   else
		   {
			 
				for( i = 0; i< lot1.length; i++)
			   {
				   temp = (lot1[i] - (lot1[i]%1e4));
				    emit refund(add1[i],temp);
					add1[i].transfer(temp); //refund if there is no winner
					total = total - temp;
			  }
		  } 
		/////////////////////////////////////////////////////////
			//check third game
			kq =a + b;
			
			for( i = 0; i< lot3.length; i++)
		   {
			   
			   if(kq ==(lot3[i]%1e4))
			   {
				   sum = sum +(lot3[i] - (lot3[i]%1e4)); //sum of people win
			   }
			   
		   }
		   if( sum > 0)
		   {
			   award = gamebalance[2]*92/100; //award foreach eth
				for( i = 0; i< lot3.length; i++)
			   {
				   if(kq ==(lot3[i]%1e4))
				   {
						temp = award*(lot3[i] - (lot3[i]%1e4))/sum;
						add3[i].transfer(temp); //increase balance of winners
						emit transfer_winner(add3[i], temp);
						total = total - temp;
				   }
				   
			   }
			 
			   sum = 0;
		   }
		   else
		   {
			   
				for( i = 0; i< lot3.length; i++)
			   {
				   temp = (lot3[i] - (lot3[i]%1e4));
				    emit refund(add3[i],temp);
					add3[i].transfer(temp); //refund if there is no winner
					total = total - temp;
			   }
		   }
		   
				//////////////////////////////////////////////////////////////
		   //check second game
			
			for( i = 0; i< lot2.length; i++)
		   {
			   
			   if(lot2[i]%1e14 == _result)
			   {
				   sum = sum + (lot2[i] - (lot2[i]%1e4)); //sum of people win
			   }
			   
		   }
		   if( sum > 0)
		   {
			   award = gamebalance[1]*92/100; //award foreach eth
				for( i = 0; i< lot2.length; i++)
			   {
				   if(lot2[i]%1e14 == _result)
				   {
					   temp = award*(lot2[i] - (lot2[i]%1e4))/sum;
						add2[i].transfer(temp); //increase balance of winners
						emit transfer_winner(add2[i],temp);
						total = total - temp;
				   }
				   
			   }
			 
			   sum = 0;
		   }
		   else
		   {
			   
				for( i = 0; i< lot2.length; i++)
			   {
				   temp = (lot2[i] - (lot2[i]%1e4));
				    emit refund(add2[i],temp);
					add2[i].transfer(temp); //refund if there is no winner
					total = total - temp;
			   }
		   }
		   
		   idmatch= 0;
		   lot1.length  =0;
		   lot2.length = 0;
		   lot3.length = 0;
		   gamebalance[0] = 0;
		   gamebalance[1] = 0;
		   gamebalance[2] = 0;
		   add1.length = 0;
		   add2.length = 0;
		   add3.length = 0;
		   if( total > 0)
		   {
				temp = total/7;
				emit transfer_jackpot(jackpot,temp);
				jackpot.transfer(temp);
				
				temp = total - temp;
				emit transfer_organization(organization,temp);
				organization.transfer(temp);
		   }
		  
		 
	   }
	
	   
   }

  
   function getBalance() public view returns (uint256)
   {
	  
	   return address(this).balance;
	   
   }
    function getBalanceAdd(address _add) public view returns (uint256)
   {
	  
	   return address(_add).balance;
	   
   }
   function getminBet() public view returns (uint256 ) {
	
	  return minbet;
	}
	 function getmaxBet() public view returns (uint256 ) {
	
	  return maxbet;
	}
   // Retrieving the adopters
	
	function getLotlistLot1(uint32 _idmatch) public view returns (uint256 []) {
		if( _idmatch == idmatch)
			return lot1;
		
	}
		
	
	function getLotlistLot2(uint32 _idmatch) public view returns (uint256 []) {
			if( _idmatch == idmatch)
			return lot2;
		
		
	}
	function getLotlistLot3(uint32 _idmatch) public view returns (uint256 []) {
		if( _idmatch == idmatch)
			return lot3;
		
		
	}
	function getadd1(uint32 _idmatch) public view returns (address []) {
		if( _idmatch == idmatch)
			return add1;
		
	}
	
	function getadd2(uint32 _idmatch) public view returns (address []) {
	if( _idmatch == idmatch)
			return add2;
		
		
	}
	function getadd3(uint32 _idmatch) public view returns (address []) {
		if( _idmatch == idmatch)
			return add3;
		
		
	}
	
	

	function getGameBalance(uint32 _idmatch) public view returns (uint256 [3]) {
	
	  if( _idmatch == idmatch)
		{
			return gamebalance;
		}
		
	}
	
	

}
