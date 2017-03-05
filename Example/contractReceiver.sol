
pragma solidity ^0.4.9;

contract Owned {
    function owned() { owner = msg.sender; }
    address owner;
    modifier onlyOwner {
        if (msg.sender != owner)
            throw;
        _;
    }
}
 
 contract contractReciever is Owned{
    //supported token contracts are stored here
    mapping (address => bool) supportedTokens;
    address public hallOfFame;
    address public testEtherToken=0x02581271ce3A0667485E5067c7B0520f2c043c40;
    
    //contract creator can add supported tokens
    function addToken(address _token) onlyOwner{
        supportedTokens[_token]=true;
    }
     
    function contractReciever()
    {
        /*We are supporting TestEtherTokens
        * when someone sends TET to this contract we will place his name in the hallOfFame variable
        */
        
        supportedTokens[0x02581271ce3A0667485E5067c7B0520f2c043c40]=true;
        owner=msg.sender;
    }
    
    function fallbackToken(address _from, uint _value){
    
        if(supportedTokens[msg.sender])
        {
            //Check if it is TestEtherToken transaction.
            if(msg.sender==testEtherToken)
            {
                hallOfFame=_from;
            }
            
            /* if(msg.sender==anotherTokenThatIsSupported)
            * { //do aother actions }
            */
        }
        //throw any accident transfers of not supported tokens
        else{ throw; }
    }
 }