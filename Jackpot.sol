pragma solidity ^0.4.24;


contract Jackpot {
	address  organization;
	address  owner;

	uint32 num;
	uint32  re;
	uint256 total;
	uint32  date;
	uint32 end;
	address [] players;
	uint256 price;
	
	//lotlisst
     uint32[] nums;
	
	 address[] adds;
	 //address[] wins;
	 uint256 [] prizes;
	// uint32 [] resnum;
	
	 
   
   
	mapping(address => uint256)  balances;
	
	event newlot(address sender, uint32 _num1);
	event distributeprizewinner(address sender, uint256 _num1);
	event distributeprizetowner( address sender,uint256 _num1);
	event newnum( uint32 _num1);
	event newrannum( uint32 _stt,uint32 _num4,uint32 date, uint256 now);
	event resultnum( uint32 _num1);
	constructor() public {
		  owner = msg.sender;
		
		 num =rand(10101010,99999999);
			
		end = 0;
		total = 0;
		re = 0;
		date = uint32(now / 60 / 60 /24) % 365;
		 price=  1e16;
		organization = 0x4ce58711a458f24ec50d005ba1edc71a114f76f5;
		
	}
	function kill() public {
      if(msg.sender == owner) selfdestruct(owner);
	}
	function() public payable {}
	function rand(uint32 min, uint32 max) internal returns (uint32){
        
        uint256 lastBlockNumber = block.number - 1;
        uint256 hashVal = uint256(blockhash(lastBlockNumber));
        
        
        // This turns the input data into a 100-sided die
        // by dividing by ceil(2 ^ 256 / 100).
        uint256 FACTOR = 115792089237316195423570985+ now;
        uint32 temp = uint32((hashVal / FACTOR)  )%max ;
		if (temp < min)
			temp = temp + min;
		return temp;
	}
	
	function _generatenumrandom() internal {
		if(((now / 60 / 60 /24) % 365) == date)
		{
			uint32 i = rand(11,99);
			uint32 temp = rand(10,99);
			uint32  num1 = (num- num%1000000)/1000000;
			uint32	num2 = (num - num1*1000000 - num%10000)/10000;
			uint32	num3 = (num - num1*1000000 - num2*10000 - num%100)/100;
			uint32	num4 = num - num1*1000000 - num2*10000 - num3*100;
			if( i%4 == 0)
			{
				num = num - (num1 - temp) * 1000000;
			}
			else
				if( i%4 == 1)
					num = num - (num2 - temp) * 10000;
				else
					if(i%4 == 2)
						num = num - (num3 - temp) * 100;
					else
						num = num - (num4 - temp) ;
			emit newrannum(i%4, num,date,now);
		}
		else
		{
			end = 1;
			re = num;
		//	re = 10101010;//to test result wwith 10-10-10-10
			emit resultnum(num);
		}
		
			
	}
	 

	
	function getNumfinal() public view returns (uint32) {
		
		return re;
		
	}
	function registry(uint32 _num) public payable returns (bool)
	{
		if( msg.value >= price)
		{
			_generatenumrandom(); // tao so random
			_deliverPrizeTokens(); //deliver price if this is the first registry of next round
			if(!checkExists(msg.sender))
			{
				players.push(msg.sender);
				balances[msg.sender] = 0 ;
			}
			balances[msg.sender] = balances[msg.sender]+msg.value; //add balance to this address
			total = total + msg.value;
			
		
			nums.push(_num);
			adds.push(msg.sender);
			emit newlot(msg.sender,_num);
			//_generatenumrandom();
		}
     
   }
function _deliverPrizeTokens(  )
    internal
  {
	  //nums.length = 0;
	  if( nums.length > 0 && end == 1)
	  {
				end = 0;
				date = uint32(now / 60 / 60 /24) % 365;
				uint32 count = 0;
				uint32 j = 0;
				for(uint32 i = 0; i < nums.length; i++){
				  	if(nums[i] == re)
					{
						 count++;
					}
				}
				if( count > 0)
				{
					uint256 ownerAmount = total *10/100; // How much each winner gets
					uint256 winnerAmount = (total -ownerAmount)/count; // How much each winner gets
					prizes.push(total);
					
					for(j = 0; j < nums.length; j++){
						if(nums[j] == re) // Check that the address in this fixed array is not empty
						{
							adds[j].transfer(winnerAmount);
							emit distributeprizewinner(adds[j],winnerAmount);
						
						}
					}
					organization.transfer(ownerAmount);//or transger to contractofgroup
					emit distributeprizetowner(organization,ownerAmount);
					nums.length = 0;
					adds.length = 0;
					players.length = 0;
					total = 0;
				}
				num =rand(10101010,99999999);
				emit newnum(num);
		}
  }
  
  
   function getBalance() public view returns (uint256)
   {
	  
	   return address(this).balance;
	   
   }
    
   function getPrizes() public view returns (uint256 []) {
	
	  return prizes;
	}
   // Retrieving the adopters
	
	function getLotlistNum() public view returns (uint32 []) {
	
	  return nums;
	}
	
	function getLotlistAdd() public view returns (address []) {
		
	  return adds;
	}
	
	function checkExists(address player) public constant returns(bool){
      for(uint32 i = 0; i < players.length; i++){
         if(players[i] == player) return true;
      }
      return false;
   }
}
