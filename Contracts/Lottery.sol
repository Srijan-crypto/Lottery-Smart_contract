// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract lottery{
    address payable immutable public manager; //manager takes conducting fees thus payable
    address payable[] private participants; //participants have to pay entry fees and also the winner has to get the prize money
    constructor(){                          // thus participants array is payable
        manager = payable(msg.sender);
    }

    function bought() private view returns(bool){ //to check whether that msg.sender has already bought a ticket or not
        for(uint i=0;i<participants.length;++i){
            if(msg.sender==participants[i])
                return true;// already bought a ticket
        }
        return false;// did not buy a ticket till now
    }

    function buyTicket() external payable { // payable function as "msg.value" is used in this function
        require(msg.sender!=manager,"manager cannot enter");
        require(bought() == false,"already bought ticket"); //you can enter the lottery only once
        require(msg.value == 1 ether,"participating fee is 1 ether");

        participants.push(payable(msg.sender));//if all 3 conditions are satisfied then add the msg.sender address to participants array
    } 

    function random() private view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty,block.number,participants)));
    }// gives a random uint number as keccak256() gives a random bytes32 data using abi.encodePacked()

    function pickWinner() external { // no need to make this function payable type as "msg.value" is not used in this function
        // winner index = random()%participants.length;   index range will be 0 to participants.length-1 as per the assigned value
        // winner address = participants[winner index];
        require(msg.sender==manager,"only manager can choose winner");
        (bool state,) = manager.call{value:3 ether}(""); //manager takes 3 ethers for conducting the lottery
        require(state == true,"Failed transaction");// in this function you can also use send() or transfer()!
        (bool state1,) = participants[random()%participants.length].call{value:address(this).balance-3}("");
        require(state1 == true,"Failed transaction");//remaining ethers are transferred to the winner's account address
        participants = new address payable[](0); // resets the lottery
    }

    function showParticipants() external view returns(address payable[] memory){
        return participants; // shows the account address of the participants
    }
}