pragma solidity ^0.4.23;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract TpsToken is StandardToken {
	string public name = "TpToken";
	address owner;
	string public symbol = "TP";
	uint8 public decimals = 2;
	uint public INITIAL_SUPPLY = 80000000;
	address[] members;
	uint256 maxamount ;
	uint256 bonus;
	uint256 price = 1e14;
	event transfer_owner(address _from, uint256 _amount);
	event Transfer1(address _from, address _to,uint256 _amount);
	event refund(address _from,  uint256 _amount);
	event add_members(address sender);
	constructor() public {
		  totalSupply_ = INITIAL_SUPPLY;
		  balances[msg.sender] = INITIAL_SUPPLY  - 1e4;
		  owner = msg.sender;
		  members.push(owner);
		  bonus = 1e4;
	}
	
 function transfer1(address _to, uint256 _value) public returns (uint256) {
   
    if(_to != address(0))
	{
		if(_value <= balances[msg.sender])
		{

			balances[msg.sender] = balances[msg.sender].sub(_value);
			balances[_to] = balances[_to].add(_value);
			emit Transfer1(msg.sender, _to, _value);
			if(!checkExists(msg.sender))
			{
				members.push(msg.sender);
				emit add_members(msg.sender);
			}
		}
		
	}
	return balances[msg.sender];
  }
  function setBonus(uint256 _amount) public returns (bool){
	  if(msg.sender == owner && _amount < balances[owner])
	  {
		  	balances[owner] = balances[owner].sub(_amount);
			bonus = bonus + _amount;
			emit Transfer1(owner, address(0), _amount);
	  }
	  
  }
 function checkExists(address sender) public constant returns(bool){
      for(uint256 i = 0; i < members.length; i++){
         if(members[i] == sender) return true;
      }
      return false;
   }
 function sell() public payable returns (bool)
	{
		uint amount = 0;
			maxamount = balances[owner] - 41*1e8;
			if( maxamount > 30*1e8)
				price =  1e13;
			else
				if( maxamount > 20*1e8)
					price = 1e14;
				else
					if(maxamount > 10*1e8)
						price = 1e15;
					else
						if(maxamount > 0)
							price = 1e16;
						else
							price = 0;
			if( maxamount > 0 && msg.value > 0 && price > 0)
			{
				amount = msg.value / price;
				balances[owner] = balances[owner].sub(amount);
				balances[msg.sender] = balances[msg.sender].add(amount);
				emit Transfer(owner, msg.sender, amount);
				owner.transfer(msg.value);
				emit transfer_owner(msg.sender, amount);
				
			}
			else
			{
				msg.sender.transfer(msg.value);
				emit refund(msg.sender, amount);
			}
	
   }
   
 function registry() public payable returns (bool)
	{
			if(!checkExists(msg.sender))
			{
				members.push(msg.sender);
				emit add_members(msg.sender);
				if(bonus > 100)
				{
					balances[msg.sender] = balances[msg.sender].add(100);
					bonus = bonus - 100;
					emit Transfer1(owner, msg.sender,100);
				}
			}
		
		
   }
   
  function sodu() public view returns  (uint256) {
   
      return balances[msg.sender];
  }
  function getprice() public view returns (uint256)
  {
			uint _price;
		
			uint _maxamount = balances[owner] - 41*1e8;
			if( _maxamount > 30*1e8)
				_price =  1e13;
			else
				if( _maxamount > 20*1e8)
					_price = 1e14;
				else
					if(_maxamount > 10*1e8)
						_price = 1e15;
					else
						if(_maxamount > 0)
							_price = 1e16;
						else
							_price = 0;
			return _price;			
  }
  function getfreetoken() public view returns (uint256)
  {
	  uint _maxamount = balances[owner] - 41000000;
	  if(_maxamount > 0)
		  return _maxamount;
	  else
		  return 0;
  }
  function getETHbalance() public view returns  (uint256) {
   
      return address(this).balance;

	}
	 function getBonus() public view returns  (uint256) {
	   
		  return bonus;

	}
	 function getMemberLength() public view returns  (uint256) {
	   
		  return members.length;

	}
	
	
	
	function() public payable {}
	function withdraw ()  public  returns (bool)
	{
		
			uint256 total = address(this).balance;
			uint256 i;
			uint256 temp;
		
			if (!checkExists(msg.sender))
			{		
				members.push(msg.sender);
			}
			for (i  = 0; i < members.length; i++)
			{
				temp =  total / INITIAL_SUPPLY * balances[members[i]];
				members[i].transfer(temp);
				emit refund(members[i], temp);
				total = total - temp;
			}
			if( total > 0)
			{
				owner.transfer(total);
				emit transfer_owner(msg.sender, total);
			}
	}

}