// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { TheCompact } from "../../src/TheCompact.sol";
import { MockERC20 } from "../../lib/solady/test/utils/mocks/MockERC20.sol";
import { ResetPeriod } from "../../src/types/ResetPeriod.sol";
import { Scope } from "../../src/types/Scope.sol";
import { Setup } from "./Setup.sol";
import { IdLib } from "../../src/lib/IdLib.sol";
import { JSONParserLib } from "../../lib/solady/src/utils/JSONParserLib.sol";
import { LibString } from "../../lib/solady/src/utils/LibString.sol";

/**
 * @title TokenURIFetchingTest
 * @notice Integration tests for tokenURI fetching functionality
 * Tests tokenURI(id) for:
 * - Native tokens (ETH) should return default ETH values
 * - Tokens with their own name/symbol/decimals should return those values
 * - Tokens without these methods should return default values
 * Uses Solady JSONParserLib to parse and validate the returned JSON
 */
contract TokenURIFetchingTest is Setup {
    using IdLib for uint96;
    using JSONParserLib for string;
    using JSONParserLib for JSONParserLib.Item;

    // Mock token that doesn't implement name/symbol/decimals
    MockERC20WithoutMetadata public tokenWithoutMetadata;

    // Mock token with custom name/symbol/decimals
    MockERC20 public customToken;

    function setUp() public override {
        super.setUp();

        // Deploy a token without metadata methods
        tokenWithoutMetadata = new MockERC20WithoutMetadata();

        // Deploy a token with custom metadata
        customToken = new MockERC20("Custom Token", "CSTM", 8);

        // Mint tokens to the swapper
        tokenWithoutMetadata.mint(swapper, 1e18);
        customToken.mint(swapper, 1e18);

        // Approve tokens for TheCompact
        vm.startPrank(swapper);
        tokenWithoutMetadata.approve(address(theCompact), 1e18);
        customToken.approve(address(theCompact), 1e18);
        vm.stopPrank();
    }

    function test_tokenURI_nativeToken() public {
        // Register allocator and create a deposit with native token (ETH)
        (, bytes12 lockTag) = _registerAllocator(alwaysOKAllocator);
        uint256 id = _makeDeposit(swapper, 1e18, lockTag);

        // Get the tokenURI for the native token
        string memory uri = theCompact.tokenURI(id);

        // Parse the JSON using Solady JSONParserLib
        JSONParserLib.Item memory json = uri.parse();

        // Verify the JSON contains the expected values
        assertEq(json.at('"name"').value(), '"Compact ETH"');

        // Verify token address is "Native Token"
        JSONParserLib.Item[] memory attributes = json.at('"attributes"').children();
        bool foundTokenAddress = false;

        for (uint256 i = 0; i < attributes.length; i++) {
            JSONParserLib.Item memory attribute = attributes[i];
            if (keccak256(bytes(attribute.at('"trait_type"').value())) == keccak256(bytes('"Token Address"'))) {
                assertEq(attribute.at('"value"').value(), '"Native Token"');
                foundTokenAddress = true;
                break;
            }
        }

        assertTrue(foundTokenAddress, "Token Address attribute not found");

        // Verify token name is "Ether"
        bool foundTokenName = false;
        for (uint256 i = 0; i < attributes.length; i++) {
            JSONParserLib.Item memory attribute = attributes[i];
            if (keccak256(bytes(attribute.at('"trait_type"').value())) == keccak256(bytes('"Token Name"'))) {
                assertEq(attribute.at('"value"').value(), '"Ether"');
                foundTokenName = true;
                break;
            }
        }

        assertTrue(foundTokenName, "Token Name attribute not found");

        // Verify token symbol is "ETH"
        bool foundTokenSymbol = false;
        for (uint256 i = 0; i < attributes.length; i++) {
            JSONParserLib.Item memory attribute = attributes[i];
            if (keccak256(bytes(attribute.at('"trait_type"').value())) == keccak256(bytes('"Token Symbol"'))) {
                assertEq(attribute.at('"value"').value(), '"ETH"');
                foundTokenSymbol = true;
                break;
            }
        }

        assertTrue(foundTokenSymbol, "Token Symbol attribute not found");

        // Verify token decimals is 18
        bool foundTokenDecimals = false;
        for (uint256 i = 0; i < attributes.length; i++) {
            JSONParserLib.Item memory attribute = attributes[i];
            if (keccak256(bytes(attribute.at('"trait_type"').value())) == keccak256(bytes('"Token Decimals"'))) {
                assertEq(attribute.at('"value"').value(), "18");
                foundTokenDecimals = true;
                break;
            }
        }

        assertTrue(foundTokenDecimals, "Token Decimals attribute not found");
    }

    function test_tokenURI_customToken() public {
        // Register allocator and create a deposit with custom token
        (, bytes12 lockTag) = _registerAllocator(alwaysOKAllocator);
        uint256 id = _makeDeposit(swapper, address(customToken), 1e18, lockTag);

        // Get the tokenURI for the custom token
        string memory uri = theCompact.tokenURI(id);

        // Parse the JSON using Solady JSONParserLib
        JSONParserLib.Item memory json = uri.parse();

        // Verify the JSON contains the expected values
        assertEq(json.at('"name"').value(), '"Compact CSTM"');

        // Verify token address is the custom token address
        JSONParserLib.Item[] memory attributes = json.at('"attributes"').children();
        bool foundTokenAddress = false;

        for (uint256 i = 0; i < attributes.length; i++) {
            JSONParserLib.Item memory attribute = attributes[i];
            if (keccak256(bytes(attribute.at('"trait_type"').value())) == keccak256(bytes('"Token Address"'))) {
                // The address should be checksummed, so we can compare with the checksummed address
                string memory value = attribute.at('"value"').value();
                // Remove the quotes from the JSON string value
                string memory valueWithoutQuotes = value;
                if (bytes(value).length >= 2 && bytes(value)[0] == '"' && bytes(value)[bytes(value).length - 1] == '"')
                {
                    // Extract the string without quotes
                    bytes memory valueBytes = bytes(value);
                    bytes memory withoutQuotes = new bytes(valueBytes.length - 2);
                    for (uint256 j = 0; j < withoutQuotes.length; j++) {
                        withoutQuotes[j] = valueBytes[j + 1];
                    }
                    valueWithoutQuotes = string(withoutQuotes);
                }

                // Get the checksummed address of the custom token
                string memory expectedAddress = LibString.toHexStringChecksummed(address(customToken));
                assertEq(
                    valueWithoutQuotes, expectedAddress, "Token address doesn't match expected checksummed address"
                );
                foundTokenAddress = true;
                break;
            }
        }

        assertTrue(foundTokenAddress, "Token Address attribute not found");

        // Verify token name is "Custom Token"
        bool foundTokenName = false;
        for (uint256 i = 0; i < attributes.length; i++) {
            JSONParserLib.Item memory attribute = attributes[i];
            if (keccak256(bytes(attribute.at('"trait_type"').value())) == keccak256(bytes('"Token Name"'))) {
                assertEq(attribute.at('"value"').value(), '"Custom Token"');
                foundTokenName = true;
                break;
            }
        }

        assertTrue(foundTokenName, "Token Name attribute not found");

        // Verify token symbol is "CSTM"
        bool foundTokenSymbol = false;
        for (uint256 i = 0; i < attributes.length; i++) {
            JSONParserLib.Item memory attribute = attributes[i];
            if (keccak256(bytes(attribute.at('"trait_type"').value())) == keccak256(bytes('"Token Symbol"'))) {
                assertEq(attribute.at('"value"').value(), '"CSTM"');
                foundTokenSymbol = true;
                break;
            }
        }

        assertTrue(foundTokenSymbol, "Token Symbol attribute not found");

        // Verify token decimals is 8
        bool foundTokenDecimals = false;
        for (uint256 i = 0; i < attributes.length; i++) {
            JSONParserLib.Item memory attribute = attributes[i];
            if (keccak256(bytes(attribute.at('"trait_type"').value())) == keccak256(bytes('"Token Decimals"'))) {
                assertEq(attribute.at('"value"').value(), "8");
                foundTokenDecimals = true;
                break;
            }
        }

        assertTrue(foundTokenDecimals, "Token Decimals attribute not found");
    }

    function test_tokenURI_tokenWithoutMetadata() public {
        // Register allocator and create a deposit with token that doesn't implement metadata
        (, bytes12 lockTag) = _registerAllocator(alwaysOKAllocator);
        uint256 id = _makeDeposit(swapper, address(tokenWithoutMetadata), 1e18, lockTag);

        // Get the tokenURI for the token without metadata
        string memory uri = theCompact.tokenURI(id);

        // Parse the JSON using Solady JSONParserLib
        JSONParserLib.Item memory json = uri.parse();

        // Verify the JSON contains the expected values
        assertEq(json.at('"name"').value(), '"Compact ???"');

        // Verify token address is the token without metadata address
        JSONParserLib.Item[] memory attributes = json.at('"attributes"').children();
        bool foundTokenAddress = false;

        for (uint256 i = 0; i < attributes.length; i++) {
            JSONParserLib.Item memory attribute = attributes[i];
            if (keccak256(bytes(attribute.at('"trait_type"').value())) == keccak256(bytes('"Token Address"'))) {
                // The address should be checksummed, so we can compare with the checksummed address
                string memory value = attribute.at('"value"').value();
                // Remove the quotes from the JSON string value
                string memory valueWithoutQuotes = value;
                if (bytes(value).length >= 2 && bytes(value)[0] == '"' && bytes(value)[bytes(value).length - 1] == '"')
                {
                    // Extract the string without quotes
                    bytes memory valueBytes = bytes(value);
                    bytes memory withoutQuotes = new bytes(valueBytes.length - 2);
                    for (uint256 j = 0; j < withoutQuotes.length; j++) {
                        withoutQuotes[j] = valueBytes[j + 1];
                    }
                    valueWithoutQuotes = string(withoutQuotes);
                }

                // Get the checksummed address of the token without metadata
                string memory expectedAddress = LibString.toHexStringChecksummed(address(tokenWithoutMetadata));
                assertEq(
                    valueWithoutQuotes, expectedAddress, "Token address doesn't match expected checksummed address"
                );
                foundTokenAddress = true;
                break;
            }
        }

        assertTrue(foundTokenAddress, "Token Address attribute not found");

        // Verify token name is "unknown token"
        bool foundTokenName = false;
        for (uint256 i = 0; i < attributes.length; i++) {
            JSONParserLib.Item memory attribute = attributes[i];
            if (keccak256(bytes(attribute.at('"trait_type"').value())) == keccak256(bytes('"Token Name"'))) {
                assertEq(attribute.at('"value"').value(), '"unknown token"');
                foundTokenName = true;
                break;
            }
        }

        assertTrue(foundTokenName, "Token Name attribute not found");

        // Verify token symbol is "???"
        bool foundTokenSymbol = false;
        for (uint256 i = 0; i < attributes.length; i++) {
            JSONParserLib.Item memory attribute = attributes[i];
            if (keccak256(bytes(attribute.at('"trait_type"').value())) == keccak256(bytes('"Token Symbol"'))) {
                assertEq(attribute.at('"value"').value(), '"???"');
                foundTokenSymbol = true;
                break;
            }
        }

        assertTrue(foundTokenSymbol, "Token Symbol attribute not found");

        // Verify token decimals is 0
        bool foundTokenDecimals = false;
        for (uint256 i = 0; i < attributes.length; i++) {
            JSONParserLib.Item memory attribute = attributes[i];
            if (keccak256(bytes(attribute.at('"trait_type"').value())) == keccak256(bytes('"Token Decimals"'))) {
                assertEq(attribute.at('"value"').value(), "0");
                foundTokenDecimals = true;
                break;
            }
        }

        assertTrue(foundTokenDecimals, "Token Decimals attribute not found");
    }

    function test_tokenURI_verifyAllAttributes() public {
        // Register allocator and create a deposit with native token (ETH)
        (, bytes12 lockTag) = _registerAllocator(alwaysOKAllocator);
        uint256 id = _makeDeposit(swapper, 1e18, lockTag);

        // Get the tokenURI for the native token
        string memory uri = theCompact.tokenURI(id);

        // Parse the JSON using Solady JSONParserLib
        JSONParserLib.Item memory json = uri.parse();

        // Verify all required attributes are present
        JSONParserLib.Item[] memory attributes = json.at('"attributes"').children();

        // Define the expected attribute names
        string[8] memory expectedAttributes = [
            "ID",
            "Token Address",
            "Token Name",
            "Token Symbol",
            "Token Decimals",
            "Allocator",
            "Scope",
            "Reset Period"
        ];

        // Check that all expected attributes are present
        for (uint256 i = 0; i < expectedAttributes.length; i++) {
            bool found = false;
            for (uint256 j = 0; j < attributes.length; j++) {
                JSONParserLib.Item memory attribute = attributes[j];
                string memory traitType = attribute.at('"trait_type"').value();
                if (
                    keccak256(abi.encodePacked(traitType))
                        == keccak256(abi.encodePacked('"', expectedAttributes[i], '"'))
                ) {
                    found = true;
                    break;
                }
            }
            assertTrue(found, string.concat("Expected attribute not found: ", expectedAttributes[i]));
        }

        // Verify the description field exists and contains expected content
        string memory description = json.at('"description"').value();
        assertTrue(bytes(description).length > 0, "Description is empty");

        // Verify the image field exists
        string memory image = json.at('"image"').value();
        assertTrue(bytes(image).length > 0, "Image is empty");
    }

    function test_tokenURI_jsonStructure() public {
        // Register allocator and create a deposit with native token (ETH)
        (, bytes12 lockTag) = _registerAllocator(alwaysOKAllocator);
        uint256 id = _makeDeposit(swapper, 1e18, lockTag);

        // Get the tokenURI for the native token
        string memory uri = theCompact.tokenURI(id);

        // Parse the JSON using Solady JSONParserLib
        JSONParserLib.Item memory json = uri.parse();

        // Verify the JSON has the expected structure
        assertTrue(json.isObject(), "JSON is not an object");

        // Check required top-level fields
        assertTrue(json.at('"name"').isString(), "name field is not a string");
        assertTrue(json.at('"description"').isString(), "description field is not a string");
        assertTrue(json.at('"image"').isString(), "image field is not a string");
        assertTrue(json.at('"attributes"').isArray(), "attributes field is not an array");

        // Check attributes structure
        JSONParserLib.Item[] memory attributes = json.at('"attributes"').children();
        assertTrue(attributes.length > 0, "attributes array is empty");

        for (uint256 i = 0; i < attributes.length; i++) {
            JSONParserLib.Item memory attribute = attributes[i];
            assertTrue(attribute.isObject(), "attribute is not an object");
            assertTrue(attribute.at('"trait_type"').isString(), "trait_type is not a string");

            // Check that the value has the correct type based on the trait_type
            string memory traitType = attribute.at('"trait_type"').value();
            if (keccak256(bytes(traitType)) == keccak256(bytes('"Token Decimals"'))) {
                // Token Decimals should be a number
                assertTrue(attribute.at('"value"').isNumber(), "Token Decimals value is not a number");
            } else {
                // All other attributes should have string values
                assertTrue(attribute.at('"value"').isString(), "Attribute value is not a string");
            }
        }
    }
}

/**
 * @title MockERC20WithoutMetadata
 * @notice A mock ERC20 token that doesn't implement name, symbol, or decimals methods
 */
contract MockERC20WithoutMetadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function mint(address to, uint256 amount) public {
        _totalSupply += amount;
        _balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}
