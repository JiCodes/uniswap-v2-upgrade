// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Test, console} from "forge-std/Test.sol";
import {UniswapV2Factory} from "../src/UniswapV2Factory.sol";
import {DeployUniswapV2Factory} from "../script/DeployUniswapV2Factory.s.sol";

contract UniswapV2FactoryTest is Test {
    UniswapV2Factory factory;

    address immutable TOKEN_A = makeAddr("tokenA");
    address immutable TOKEN_B = makeAddr("tokenB");
    address immutable FEE_TO_SETTER = makeAddr("FEE_TO_SETTER");
    address immutable FEE_TO = makeAddr("FEE_TO");

    function setUp() external {
        DeployUniswapV2Factory deployFactory = new DeployUniswapV2Factory();
        factory = deployFactory.run(FEE_TO_SETTER);
    }

    function testFeeToAndFeeToSetter() public {
        assertEq(factory.feeToSetter(), FEE_TO_SETTER); // Assuming OWNER is the feeToSetter
        assertEq(factory.feeTo(), address(0)); // Assuming feeTo is not set
        assertEq(factory.allPairsLength(), 0); // Assuming no pair has been created
    }

    function testCreatePair() public {
        factory.createPair(TOKEN_A, TOKEN_B);
        assertEq(factory.allPairsLength(), 1);

        // Test that creating the same pair again reverts
        (bool success, ) = address(factory).call(
            abi.encodeWithSignature(
                "createPair(address,address)",
                TOKEN_A,
                TOKEN_B
            )
        );
        assertFalse(success);

        // Test that creating the pair with reversed token addresses also reverts
        (bool successReversed, ) = address(factory).call(
            abi.encodeWithSignature(
                "createPair(address,address)",
                TOKEN_B,
                TOKEN_A
            )
        );
        assertFalse(successReversed);

        // Test that creating the pair with identical token addresses also reverts

        address identicalAddress = TOKEN_A;
        (bool successIdentical, ) = address(factory).call(
            abi.encodeWithSignature(
                "createPair(address,address)",
                identicalAddress,
                identicalAddress
            )
        );
        assertFalse(
            successIdentical,
            "Expecting a revert for IDENTICAL_ADDRESSES"
        );

        // Test that creating the pair with zero address also reverts
        address zeroAddress = address(0);
        (bool successZeroAddress, ) = address(factory).call(
            abi.encodeWithSignature(
                "createPair(address,address)",
                zeroAddress,
                TOKEN_B
            )
        );
        assertFalse(successZeroAddress, "Expecting a revert for ZERO_ADDRESS");
    }

    function testSetFeeTo() public {
        address other = makeAddr("other");
        (bool success, ) = address(factory).call(
            abi.encodeWithSignature("setFeeTo(address)", other)
        );
        assertFalse(success); // Expecting a revert

        vm.prank(FEE_TO_SETTER);
        factory.setFeeTo(FEE_TO);
        assertEq(factory.feeTo(), FEE_TO);
    }

    function testSetFeeToSetter() public {
        address other = makeAddr("other");
        vm.prank(other);
        (bool success, ) = address(factory).call(
            abi.encodeWithSignature("setFeeToSetter(address)", other)
        );
        assertFalse(success); // Expecting a revert

        vm.prank(FEE_TO_SETTER);
        factory.setFeeToSetter(FEE_TO_SETTER);
        assertEq(factory.feeToSetter(), FEE_TO_SETTER);
    }
}
