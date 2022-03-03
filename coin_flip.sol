// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract CoinFlip {
    struct BetPlay {
        uint id;
        address player;
        bytes32 predict;
        uint256 amount;
        bool decided;
    }

    uint counter;
    mapping(address => uint256) public userAccounts;
    mapping(uint => BetPlay) public betsPlayed;

    function joinBet(address player) public {
        userAccounts[player] = 100;
    }
  
    function vrf() public view returns (bytes32 result) {
        uint[1] memory bn;
        bn[0] = block.number;
        assembly {
            let memPtr := mload(0x40)
            if iszero(staticcall(not(0), 0xff, bn, 0x20, memPtr, 0x20)) {
                invalid()
            }
            result := mload(memPtr)
        }
    }
    
    function startPlay(address player, uint256 amount, bytes32 predict) payable public {
        require (userAccounts[player] >= amount);
        bool flag = true;
        for (uint j = 0; j<counter; j++) {
            if (betsPlayed[j].player == player && !betsPlayed[j].decided) {
                flag = false;
            }
        }
        require(flag);
        userAccounts[player] -= amount;
        betsPlayed[counter] = BetPlay(counter, player, predict, amount, false);
        counter++;
    }

    function rewardBets() payable public {
        bytes32 result = vrf();
        for (uint j = 0; j < counter; j++) {
            if (!betsPlayed[j].decided) {
                if (result == betsPlayed[j].predict){
                    userAccounts[betsPlayed[j].player] += 2*betsPlayed[j].amount;
                }
                betsPlayed[j].decided = true;
            }
        }
    }
}