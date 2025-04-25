// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console } from "forge-std/Test.sol";
import { TheCompact } from "../../src/TheCompact.sol";
import { MockERC20 } from "../../lib/solady/test/utils/mocks/MockERC20.sol";
import { Compact, BatchCompact, Element } from "../../src/types/EIP712Types.sol";
import { ResetPeriod } from "../../src/types/ResetPeriod.sol";
import { Scope } from "../../src/types/Scope.sol";
import { CompactCategory } from "../../src/types/CompactCategory.sol";
import { DepositDetails } from "../../src/types/DepositDetails.sol";
import { ISignatureTransfer } from "permit2/src/interfaces/ISignatureTransfer.sol";

import { HashLib } from "../../src/lib/HashLib.sol";
import { IdLib } from "../../src/lib/IdLib.sol";

import { AlwaysOKAllocator } from "../../src/test/AlwaysOKAllocator.sol";
import { AlwaysOKEmissary } from "../../src/test/AlwaysOKEmissary.sol";
import { SimpleAllocator } from "../../src/examples/allocator/SimpleAllocator.sol";
import { QualifiedAllocator } from "../../src/examples/allocator/QualifiedAllocator.sol";

import { AllocatedTransfer, Claim } from "../../src/types/Claims.sol";
import { AllocatedBatchTransfer, BatchClaim } from "../../src/types/BatchClaims.sol";

import { MultichainClaim, ExogenousMultichainClaim } from "../../src/types/MultichainClaims.sol";

import { BatchMultichainClaim, ExogenousBatchMultichainClaim } from "../../src/types/BatchMultichainClaims.sol";

import { Component, TransferComponent, ComponentsById, BatchClaimComponent } from "../../src/types/Components.sol";

import {
    EIP712,
    Setup,
    TestParams,
    LockDetails,
    CreatePermitBatchWitnessDigestArgs,
    SetupPermitCallExpectationArgs,
    CreateClaimHashWithWitnessArgs,
    CreateBatchClaimHashWithWitnessArgs
} from "./Setup.sol";

contract TheCompactTest is Setup {
    using IdLib for uint96;

    function setUp() public virtual override {
        super.setUp();
    }

    function test_name() public view {
        string memory name = theCompact.name();
        assertEq(keccak256(bytes(name)), keccak256(bytes("The Compact")));
    }

    function test_domainSeparator() public view {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                compactEIP712DomainHash,
                keccak256(bytes("The Compact")),
                keccak256(bytes("1")),
                block.chainid,
                address(theCompact)
            )
        );
        assertEq(domainSeparator, theCompact.DOMAIN_SEPARATOR());
    }

    function test_domainSeparatorOnNewChain() public {
        uint256 currentChainId = block.chainid;
        uint256 differentChainId = currentChainId + 42;
        bytes32 domainSeparator = keccak256(
            abi.encode(
                compactEIP712DomainHash,
                keccak256(bytes("The Compact")),
                keccak256(bytes("1")),
                differentChainId,
                address(theCompact)
            )
        );
        vm.chainId(differentChainId);
        assertEq(block.chainid, differentChainId);
        assertEq(domainSeparator, theCompact.DOMAIN_SEPARATOR());
        vm.chainId(currentChainId);
        assertEq(block.chainid, currentChainId);
    }

    function test_depositETHBasic() public {
        address recipient = swapper;
        ResetPeriod resetPeriod = ResetPeriod.TenMinutes;
        Scope scope = Scope.Multichain;
        uint256 amount = 1e18;

        vm.prank(allocator);
        uint96 allocatorId = theCompact.__registerAllocator(allocator, "");

        bytes12 lockTag =
            bytes12(bytes32((uint256(scope) << 255) | (uint256(resetPeriod) << 252) | (uint256(allocatorId) << 160)));

        vm.prank(swapper);
        uint256 id = theCompact.depositNative{ value: amount }(lockTag, address(0));
        vm.snapshotGasLastCall("depositETHBasic");

        (
            address derivedToken,
            address derivedAllocator,
            ResetPeriod derivedResetPeriod,
            Scope derivedScope,
            bytes12 derivedLockTag
        ) = theCompact.getLockDetails(id);
        assertEq(derivedToken, address(0));
        assertEq(derivedAllocator, allocator);
        assertEq(uint256(derivedResetPeriod), uint256(resetPeriod));
        assertEq(uint256(derivedScope), uint256(scope));
        assertEq(
            id,
            (uint256(scope) << 255) | (uint256(resetPeriod) << 252) | (uint256(allocatorId) << 160)
                | uint256(uint160(address(0)))
        );
        assertEq(
            derivedLockTag,
            bytes12(bytes32((uint256(scope) << 255) | (uint256(resetPeriod) << 252) | (uint256(allocatorId) << 160)))
        );

        assertEq(address(theCompact).balance, amount);
        assertEq(theCompact.balanceOf(recipient, id), amount);
        assert(bytes(theCompact.tokenURI(id)).length > 0);
    }

    function test_depositETHAndURI() public {
        address recipient = 0x1111111111111111111111111111111111111111;
        ResetPeriod resetPeriod = ResetPeriod.TenMinutes;
        Scope scope = Scope.Multichain;
        uint256 amount = 1e18;

        vm.prank(allocator);
        uint96 allocatorId = theCompact.__registerAllocator(allocator, "");

        bytes12 lockTag =
            bytes12(bytes32((uint256(scope) << 255) | (uint256(resetPeriod) << 252) | (uint256(allocatorId) << 160)));

        vm.prank(swapper);
        uint256 id = theCompact.depositNative{ value: amount }(lockTag, recipient);
        vm.snapshotGasLastCall("depositETHAndURI");

        (
            address derivedToken,
            address derivedAllocator,
            ResetPeriod derivedResetPeriod,
            Scope derivedScope,
            bytes12 derivedLockTag
        ) = theCompact.getLockDetails(id);
        assertEq(derivedToken, address(0));
        assertEq(derivedAllocator, allocator);
        assertEq(uint256(derivedResetPeriod), uint256(resetPeriod));
        assertEq(uint256(derivedScope), uint256(scope));
        assertEq(
            id,
            (uint256(scope) << 255) | (uint256(resetPeriod) << 252) | (uint256(allocatorId) << 160)
                | uint256(uint160(address(0)))
        );
        assertEq(
            derivedLockTag,
            bytes12(bytes32((uint256(scope) << 255) | (uint256(resetPeriod) << 252) | (uint256(allocatorId) << 160)))
        );

        assertEq(address(theCompact).balance, amount);
        assertEq(theCompact.balanceOf(recipient, id), amount);
        assert(bytes(theCompact.tokenURI(id)).length > 0);
    }

    function test_depositERC20Basic() public {
        address recipient = swapper;
        ResetPeriod resetPeriod = ResetPeriod.TenMinutes;
        Scope scope = Scope.Multichain;
        uint256 amount = 1e18;

        vm.prank(allocator);
        uint96 allocatorId = theCompact.__registerAllocator(allocator, "");

        bytes12 lockTag =
            bytes12(bytes32((uint256(scope) << 255) | (uint256(resetPeriod) << 252) | (uint256(allocatorId) << 160)));

        vm.prank(swapper);
        uint256 id = theCompact.depositERC20(address(token), lockTag, amount, swapper);
        vm.snapshotGasLastCall("depositERC20Basic");

        (
            address derivedToken,
            address derivedAllocator,
            ResetPeriod derivedResetPeriod,
            Scope derivedScope,
            bytes12 derivedLockTag
        ) = theCompact.getLockDetails(id);
        assertEq(derivedToken, address(token));
        assertEq(derivedAllocator, allocator);
        assertEq(uint256(derivedResetPeriod), uint256(resetPeriod));
        assertEq(uint256(derivedScope), uint256(scope));
        assertEq(
            id,
            (uint256(scope) << 255) | (uint256(resetPeriod) << 252) | (uint256(allocatorId) << 160)
                | uint256(uint160(address(token)))
        );
        assertEq(
            derivedLockTag,
            bytes12(bytes32((uint256(scope) << 255) | (uint256(resetPeriod) << 252) | (uint256(allocatorId) << 160)))
        );

        assertEq(token.balanceOf(address(theCompact)), amount);
        assertEq(theCompact.balanceOf(recipient, id), amount);
        assert(bytes(theCompact.tokenURI(id)).length > 0);
    }

    function test_depositERC20AndURI() public {
        address recipient = 0x1111111111111111111111111111111111111111;
        ResetPeriod resetPeriod = ResetPeriod.TenMinutes;
        Scope scope = Scope.Multichain;
        uint256 amount = 1e18;

        vm.prank(allocator);
        uint96 allocatorId = theCompact.__registerAllocator(allocator, "");

        bytes12 lockTag =
            bytes12(bytes32((uint256(scope) << 255) | (uint256(resetPeriod) << 252) | (uint256(allocatorId) << 160)));

        vm.prank(swapper);
        uint256 id = theCompact.depositERC20(address(token), lockTag, amount, recipient);
        vm.snapshotGasLastCall("depositERC20AndURI");

        (
            address derivedToken,
            address derivedAllocator,
            ResetPeriod derivedResetPeriod,
            Scope derivedScope,
            bytes12 derivedLockTag
        ) = theCompact.getLockDetails(id);
        assertEq(derivedToken, address(token));
        assertEq(derivedAllocator, allocator);
        assertEq(uint256(derivedResetPeriod), uint256(resetPeriod));
        assertEq(uint256(derivedScope), uint256(scope));
        assertEq(
            id,
            (uint256(scope) << 255) | (uint256(resetPeriod) << 252) | (uint256(allocatorId) << 160)
                | uint256(uint160(address(token)))
        );
        assertEq(
            derivedLockTag,
            bytes12(bytes32((uint256(scope) << 255) | (uint256(resetPeriod) << 252) | (uint256(allocatorId) << 160)))
        );

        assertEq(token.balanceOf(address(theCompact)), amount);
        assertEq(theCompact.balanceOf(recipient, id), amount);
        assert(bytes(theCompact.tokenURI(id)).length > 0);
    }

    function test_depositBatchSingleNativeToken() public {
        address recipient = 0x1111111111111111111111111111111111111111;
        ResetPeriod resetPeriod = ResetPeriod.TenMinutes;
        Scope scope = Scope.Multichain;
        uint256 amount = 1e18;

        vm.prank(allocator);
        uint96 allocatorId = theCompact.__registerAllocator(allocator, "");

        uint256 id = (
            (uint256(scope) << 255) | (uint256(resetPeriod) << 252) | (uint256(allocatorId) << 160)
                | uint256(uint160(address(0)))
        );

        {
            uint256[2][] memory idsAndAmounts = new uint256[2][](1);
            idsAndAmounts[0] = [id, amount];

            vm.prank(swapper);
            bool ok = theCompact.batchDeposit{ value: amount }(idsAndAmounts, recipient);
            vm.snapshotGasLastCall("depositBatchSingleNative");
            assert(ok);
        }

        (
            address derivedToken,
            address derivedAllocator,
            ResetPeriod derivedResetPeriod,
            Scope derivedScope,
            bytes12 lockTag
        ) = theCompact.getLockDetails(id);
        assertEq(derivedToken, address(0));
        assertEq(derivedAllocator, allocator);
        assertEq(uint256(derivedResetPeriod), uint256(resetPeriod));
        assertEq(uint256(derivedScope), uint256(scope));

        assertEq(
            id,
            (uint256(scope) << 255) | (uint256(resetPeriod) << 252) | (uint256(allocatorId) << 160)
                | uint256(uint160(address(0)))
        );
        assertEq(
            lockTag,
            bytes12(bytes32((uint256(scope) << 255) | (uint256(resetPeriod) << 252) | (uint256(allocatorId) << 160)))
        );

        assertEq(address(theCompact).balance, amount);
        assertEq(theCompact.balanceOf(recipient, id), amount);
        assert(bytes(theCompact.tokenURI(id)).length > 0);
    }

    function test_depositBatchSingleERC20() public {
        address recipient = 0x1111111111111111111111111111111111111111;
        ResetPeriod resetPeriod = ResetPeriod.TenMinutes;
        Scope scope = Scope.Multichain;
        uint256 amount = 1e18;

        vm.prank(allocator);
        uint96 allocatorId = theCompact.__registerAllocator(allocator, "");

        uint256 id = (
            (uint256(scope) << 255) | (uint256(resetPeriod) << 252) | (uint256(allocatorId) << 160)
                | uint256(uint160(address(token)))
        );

        {
            uint256[2][] memory idsAndAmounts = new uint256[2][](1);
            idsAndAmounts[0] = [id, amount];

            vm.prank(swapper);
            bool ok = theCompact.batchDeposit(idsAndAmounts, recipient);
            vm.snapshotGasLastCall("depositBatchSingleERC20");
            assert(ok);
        }

        (
            address derivedToken,
            address derivedAllocator,
            ResetPeriod derivedResetPeriod,
            Scope derivedScope,
            bytes12 lockTag
        ) = theCompact.getLockDetails(id);
        assertEq(derivedToken, address(token));
        assertEq(derivedAllocator, allocator);
        assertEq(uint256(derivedResetPeriod), uint256(resetPeriod));
        assertEq(uint256(derivedScope), uint256(scope));

        assertEq(
            id,
            (uint256(scope) << 255) | (uint256(resetPeriod) << 252) | (uint256(allocatorId) << 160)
                | uint256(uint160(address(token)))
        );
        assertEq(
            lockTag,
            bytes12(bytes32((uint256(scope) << 255) | (uint256(resetPeriod) << 252) | (uint256(allocatorId) << 160)))
        );

        assertEq(token.balanceOf(address(theCompact)), amount);
        assertEq(theCompact.balanceOf(recipient, id), amount);
        assert(bytes(theCompact.tokenURI(id)).length > 0);
    }

    function _createPermitWitnessDigest(
        bytes32 domainSeparator,
        address permitToken,
        uint256 amount,
        address spender,
        uint256 nonce,
        uint256 deadline,
        bytes32 witnessHash
    ) internal pure returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                bytes2(0x1901),
                domainSeparator,
                keccak256(
                    abi.encode(
                        keccak256(
                            "PermitWitnessTransferFrom(TokenPermissions permitted,address spender,uint256 nonce,uint256 deadline,CompactDeposit witness)CompactDeposit(bytes12 lockTag,address recipient)TokenPermissions(address token,uint256 amount)"
                        ),
                        keccak256(
                            abi.encode(keccak256("TokenPermissions(address token,uint256 amount)"), permitToken, amount)
                        ),
                        spender,
                        nonce,
                        deadline,
                        witnessHash
                    )
                )
            )
        );
    }

    function test_depositERC20ViaPermit2AndURI() public virtual {
        // Setup test variables
        TestParams memory params;
        params.recipient = 0x1111111111111111111111111111111111111111;
        params.resetPeriod = ResetPeriod.TenMinutes;
        params.scope = Scope.Multichain;
        params.amount = 1e18;
        params.nonce = 0;
        params.deadline = block.timestamp + 1000;

        // Register allocator and create lock tag
        uint96 allocatorId;
        bytes12 lockTag;
        {
            vm.prank(allocator);
            allocatorId = theCompact.__registerAllocator(allocator, "");

            lockTag = bytes12(
                bytes32(
                    (uint256(params.scope) << 255) | (uint256(params.resetPeriod) << 252)
                        | (uint256(allocatorId) << 160)
                )
            );
        }

        // Create domain separator and digest
        bytes32 domainSeparator;
        bytes32 digest;
        {
            domainSeparator = keccak256(
                abi.encode(permit2EIP712DomainHash, keccak256(bytes("Permit2")), block.chainid, address(permit2))
            );

            assertEq(domainSeparator, EIP712(permit2).DOMAIN_SEPARATOR());

            bytes32 witnessHash = keccak256(
                abi.encode(keccak256("CompactDeposit(bytes12 lockTag,address recipient)"), lockTag, params.recipient)
            );

            digest = _createPermitWitnessDigest(
                domainSeparator,
                address(token),
                params.amount,
                address(theCompact),
                params.nonce,
                params.deadline,
                witnessHash
            );
        }

        // Create signature and permit
        bytes memory signature;
        ISignatureTransfer.PermitTransferFrom memory permit;
        {
            (bytes32 r, bytes32 vs) = vm.signCompact(swapperPrivateKey, digest);
            signature = abi.encodePacked(r, vs);

            permit = ISignatureTransfer.PermitTransferFrom({
                permitted: ISignatureTransfer.TokenPermissions({ token: address(token), amount: params.amount }),
                nonce: params.nonce,
                deadline: params.deadline
            });
        }

        // Setup expectations and make deposit
        uint256 id;
        {
            bytes32 witnessHash = keccak256(
                abi.encode(keccak256("CompactDeposit(bytes12 lockTag,address recipient)"), lockTag, params.recipient)
            );

            vm.expectCall(
                address(permit2),
                abi.encodeWithSignature(
                    "permitWitnessTransferFrom(((address,uint256),uint256,uint256),(address,uint256),address,bytes32,string,bytes)",
                    permit,
                    ISignatureTransfer.SignatureTransferDetails({
                        to: address(theCompact),
                        requestedAmount: params.amount
                    }),
                    swapper,
                    witnessHash,
                    "CompactDeposit witness)CompactDeposit(bytes12 lockTag,address recipient)TokenPermissions(address token,uint256 amount)",
                    signature
                )
            );

            id = theCompact.depositERC20ViaPermit2(permit, swapper, lockTag, params.recipient, signature);
            vm.snapshotGasLastCall("depositERC20ViaPermit2AndURI");
        }

        // Verify lock details
        {
            LockDetails memory lockDetails;
            (lockDetails.token, lockDetails.allocator, lockDetails.resetPeriod, lockDetails.scope, lockDetails.lockTag)
            = theCompact.getLockDetails(id);

            assertEq(lockDetails.token, address(token));
            assertEq(lockDetails.allocator, allocator);
            assertEq(uint256(lockDetails.resetPeriod), uint256(params.resetPeriod));
            assertEq(uint256(lockDetails.scope), uint256(params.scope));
            assertEq(
                id,
                (uint256(params.scope) << 255) | (uint256(params.resetPeriod) << 252) | (uint256(allocatorId) << 160)
                    | uint256(uint160(address(token)))
            );
            assertEq(lockDetails.lockTag, lockTag);
        }

        // Verify balances and token URI
        {
            assertEq(token.balanceOf(address(theCompact)), params.amount);
            assertEq(theCompact.balanceOf(params.recipient, id), params.amount);
            assert(bytes(theCompact.tokenURI(id)).length > 0);
        }
    }

    function _verifyLockDetails(
        uint256 id,
        TestParams memory params,
        LockDetails memory expectedDetails,
        uint96 allocatorId
    ) internal view {
        LockDetails memory actualDetails;

        (
            actualDetails.token,
            actualDetails.allocator,
            actualDetails.resetPeriod,
            actualDetails.scope,
            actualDetails.lockTag
        ) = theCompact.getLockDetails(id);

        assertEq(actualDetails.token, expectedDetails.token);
        assertEq(actualDetails.allocator, expectedDetails.allocator);
        assertEq(uint256(actualDetails.resetPeriod), uint256(params.resetPeriod));
        assertEq(uint256(actualDetails.scope), uint256(params.scope));
        assertEq(
            id,
            (uint256(params.scope) << 255) | (uint256(params.resetPeriod) << 252) | (uint256(allocatorId) << 160)
                | uint256(uint160(expectedDetails.token))
        );
        assertEq(actualDetails.lockTag, expectedDetails.lockTag);
    }

    function test_depositBatchViaPermit2SingleERC20() public virtual {
        // Setup test variables
        TestParams memory params;
        params.recipient = 0x1111111111111111111111111111111111111111;
        params.resetPeriod = ResetPeriod.TenMinutes;
        params.scope = Scope.Multichain;
        params.amount = 1e18;
        params.nonce = 0;
        params.deadline = block.timestamp + 1000;

        // Register allocator and create lock tag
        uint96 allocatorId;
        bytes12 lockTag;
        {
            (allocatorId, lockTag) = _registerAllocator(allocator);
        }

        // Create domain separator
        bytes32 domainSeparator;
        {
            domainSeparator = keccak256(
                abi.encode(permit2EIP712DomainHash, keccak256(bytes("Permit2")), block.chainid, address(permit2))
            );

            assertEq(domainSeparator, EIP712(permit2).DOMAIN_SEPARATOR());
        }

        // Prepare tokens and amounts arrays
        address[] memory tokens;
        uint256[] memory amounts;
        {
            tokens = new address[](1);
            amounts = new uint256[](1);
            tokens[0] = address(token);
            amounts[0] = params.amount;
        }

        // Create signature and token permissions
        bytes memory signature;
        ISignatureTransfer.PermitBatchTransferFrom memory permit;
        ISignatureTransfer.SignatureTransferDetails[] memory signatureTransferDetails;

        {
            ISignatureTransfer.TokenPermissions[] memory tokenPermissions;
            {
                (signature, tokenPermissions) = _createPermit2BatchSignature(
                    tokens, amounts, params.nonce, params.deadline, lockTag, params.recipient, swapperPrivateKey
                );
            }

            // Create permit and transfer details
            {
                signatureTransferDetails = new ISignatureTransfer.SignatureTransferDetails[](1);
                signatureTransferDetails[0] = ISignatureTransfer.SignatureTransferDetails({
                    to: address(theCompact),
                    requestedAmount: params.amount
                });

                permit = ISignatureTransfer.PermitBatchTransferFrom({
                    permitted: tokenPermissions,
                    nonce: params.nonce,
                    deadline: params.deadline
                });
            }
        }

        uint256[] memory ids;

        {
            // Prepare deposit details and expectations
            DepositDetails memory details;

            {
                details = DepositDetails({ nonce: params.nonce, deadline: params.deadline, lockTag: lockTag });

                bytes32 witnessHash = keccak256(
                    abi.encode(
                        keccak256("CompactDeposit(bytes12 lockTag,address recipient)"), lockTag, params.recipient
                    )
                );

                vm.expectCall(
                    address(permit2),
                    abi.encodeWithSignature(
                        "permitWitnessTransferFrom(((address,uint256)[],uint256,uint256),(address,uint256)[],address,bytes32,string,bytes)",
                        permit,
                        signatureTransferDetails,
                        swapper,
                        witnessHash,
                        "CompactDeposit witness)CompactDeposit(bytes12 lockTag,address recipient)TokenPermissions(address token,uint256 amount)",
                        signature
                    )
                );
            }

            // Make deposit
            {
                ids = theCompact.batchDepositViaPermit2(swapper, permit.permitted, details, params.recipient, signature);
                vm.snapshotGasLastCall("depositBatchViaPermit2SingleERC20");

                assertEq(ids.length, 1);
            }
        }

        // Verify lock details
        {
            LockDetails memory expectedDetails;
            expectedDetails.token = address(token);
            expectedDetails.allocator = allocator;
            expectedDetails.resetPeriod = params.resetPeriod;
            expectedDetails.scope = params.scope;
            expectedDetails.lockTag = lockTag;

            _verifyLockDetails(ids[0], params, expectedDetails, allocatorId);
        }

        // Verify balances and token URI
        {
            assertEq(token.balanceOf(address(theCompact)), params.amount);
            assertEq(theCompact.balanceOf(params.recipient, ids[0]), params.amount);
            assert(bytes(theCompact.tokenURI(ids[0])).length > 0);
        }
    }

    function test_depositBatchViaPermit2NativeAndERC20() public virtual {
        // Setup test variables
        TestParams memory params;
        params.recipient = 0x1111111111111111111111111111111111111111;
        params.resetPeriod = ResetPeriod.TenMinutes;
        params.scope = Scope.Multichain;
        params.amount = 1e18;
        params.nonce = 0;
        params.deadline = block.timestamp + 1000;

        // Register allocator and create lock tag
        uint96 allocatorId;
        bytes12 lockTag;
        {
            (allocatorId, lockTag) = _registerAllocator(allocator);
        }

        // Create domain separator
        bytes32 domainSeparator;
        {
            domainSeparator = keccak256(
                abi.encode(permit2EIP712DomainHash, keccak256(bytes("Permit2")), block.chainid, address(permit2))
            );

            assertEq(domainSeparator, EIP712(permit2).DOMAIN_SEPARATOR());
        }

        // Prepare tokens and amounts arrays
        address[] memory tokens;
        uint256[] memory amounts;
        {
            tokens = new address[](2);
            amounts = new uint256[](2);
            tokens[0] = address(0);
            amounts[0] = params.amount;
            tokens[1] = address(token);
            amounts[1] = params.amount;
        }

        // Create signature and token permissions
        bytes memory signature;
        ISignatureTransfer.TokenPermissions[] memory tokenPermissions;
        {
            (signature, tokenPermissions) = _createPermit2BatchSignature(
                tokens, amounts, params.nonce, params.deadline, lockTag, params.recipient, swapperPrivateKey
            );
        }

        uint256[] memory ids;

        {
            {
                // Create permit and transfer details for the ERC20 token
                ISignatureTransfer.SignatureTransferDetails[] memory signatureTransferDetails;
                ISignatureTransfer.PermitBatchTransferFrom memory permitOnCall;
                {
                    ISignatureTransfer.TokenPermissions[] memory tokenPermissionsOnCall;
                    {
                        tokenPermissionsOnCall = new ISignatureTransfer.TokenPermissions[](1);
                        tokenPermissionsOnCall[0] =
                            ISignatureTransfer.TokenPermissions({ token: address(token), amount: params.amount });
                    }

                    {
                        signatureTransferDetails = new ISignatureTransfer.SignatureTransferDetails[](1);
                        signatureTransferDetails[0] = ISignatureTransfer.SignatureTransferDetails({
                            to: address(theCompact),
                            requestedAmount: params.amount
                        });
                    }

                    {
                        permitOnCall = ISignatureTransfer.PermitBatchTransferFrom({
                            permitted: tokenPermissionsOnCall,
                            nonce: params.nonce,
                            deadline: params.deadline
                        });
                    }
                }

                bytes32 witnessHash;
                {
                    witnessHash = keccak256(
                        abi.encode(
                            keccak256("CompactDeposit(bytes12 lockTag,address recipient)"), lockTag, params.recipient
                        )
                    );

                    vm.expectCall(
                        address(permit2),
                        abi.encodeWithSignature(
                            "permitWitnessTransferFrom(((address,uint256)[],uint256,uint256),(address,uint256)[],address,bytes32,string,bytes)",
                            permitOnCall,
                            signatureTransferDetails,
                            swapper,
                            witnessHash,
                            "CompactDeposit witness)CompactDeposit(bytes12 lockTag,address recipient)TokenPermissions(address token,uint256 amount)",
                            signature
                        )
                    );
                }
            }

            // Make deposit
            {
                DepositDetails memory details =
                    DepositDetails({ nonce: params.nonce, deadline: params.deadline, lockTag: lockTag });

                ids = theCompact.batchDepositViaPermit2{ value: params.amount }(
                    swapper, tokenPermissions, details, params.recipient, signature
                );
                vm.snapshotGasLastCall("depositBatchViaPermit2NativeAndERC20");

                assertEq(ids.length, 2);
            }
        }

        // Verify lock details for ETH (native token)
        {
            LockDetails memory expectedDetails;
            expectedDetails.token = address(0);
            expectedDetails.allocator = allocator;
            expectedDetails.resetPeriod = params.resetPeriod;
            expectedDetails.scope = params.scope;
            expectedDetails.lockTag = lockTag;

            _verifyLockDetails(ids[0], params, expectedDetails, allocatorId);
        }

        // Verify id for ERC20 token
        {
            assertEq(
                ids[1],
                (uint256(params.scope) << 255) | (uint256(params.resetPeriod) << 252) | (uint256(allocatorId) << 160)
                    | uint256(uint160(address(token)))
            );
        }

        // Verify balances and token URIs
        {
            assertEq(token.balanceOf(address(theCompact)), params.amount);
            assertEq(address(theCompact).balance, params.amount);
            assertEq(theCompact.balanceOf(params.recipient, ids[0]), params.amount);
            assertEq(theCompact.balanceOf(params.recipient, ids[1]), params.amount);
            assert(bytes(theCompact.tokenURI(ids[0])).length > 0);
        }
    }

    function test_Transfer() public {
        // Setup test parameters
        TestParams memory params;
        params.resetPeriod = ResetPeriod.TenMinutes;
        params.scope = Scope.Multichain;
        params.amount = 1e18;
        params.nonce = 0;
        params.deadline = block.timestamp + 1000;

        // Recipient information
        address recipientOne = 0x1111111111111111111111111111111111111111;
        address recipientTwo = 0x2222222222222222222222222222222222222222;
        uint256 amountOne = 4e17;
        uint256 amountTwo = 6e17;

        // Register allocator and create lock tag
        uint256 id;
        {
            uint96 allocatorId;
            bytes12 lockTag;
            (allocatorId, lockTag) = _registerAllocator(allocator);

            // Make deposit
            id = _makeDeposit(swapper, address(token), params.amount, lockTag);
        }

        // Create digest and allocator signature
        bytes memory allocatorData;
        {
            bytes32 claimHash =
                _createClaimHash(compactTypehash, swapper, swapper, params.nonce, params.deadline, id, params.amount);

            bytes32 digest = _createDigest(theCompact.DOMAIN_SEPARATOR(), claimHash);

            bytes32 r;
            bytes32 vs;
            (r, vs) = vm.signCompact(allocatorPrivateKey, digest);
            allocatorData = abi.encodePacked(r, vs);
        }

        // Prepare recipients
        Component[] memory recipients;
        {
            uint256 claimantOne = abi.decode(abi.encodePacked(bytes12(bytes32(id)), recipientOne), (uint256));
            uint256 claimantTwo = abi.decode(abi.encodePacked(bytes12(bytes32(id)), recipientTwo), (uint256));

            Component memory splitOne = Component({ claimant: claimantOne, amount: amountOne });
            Component memory splitTwo = Component({ claimant: claimantTwo, amount: amountTwo });

            recipients = new Component[](2);
            recipients[0] = splitOne;
            recipients[1] = splitTwo;
        }

        // Create and execute transfer
        AllocatedTransfer memory transfer = AllocatedTransfer({
            nonce: params.nonce,
            expires: params.deadline,
            allocatorData: allocatorData,
            id: id,
            recipients: recipients
        });

        vm.prank(swapper);
        bool status = theCompact.allocatedTransfer(transfer);
        vm.snapshotGasLastCall("Transfer");
        assert(status);

        // Verify balances
        assertEq(token.balanceOf(address(theCompact)), params.amount);
        assertEq(token.balanceOf(recipientOne), 0);
        assertEq(theCompact.balanceOf(swapper, id), 0);
        assertEq(theCompact.balanceOf(recipientOne, id), amountOne);
        assertEq(theCompact.balanceOf(recipientTwo, id), amountTwo);
    }

    function test_qualified_basicTransfer() public {
        // Setup test parameters
        TestParams memory params;
        params.resetPeriod = ResetPeriod.TenMinutes;
        params.scope = Scope.Multichain;
        params.amount = 1e18;
        params.nonce = 0;
        params.deadline = block.timestamp + 1000;
        params.recipient = 0x1111111111111111111111111111111111111111;

        // Setup qualified allocator
        uint256 id;
        {
            allocator = address(new QualifiedAllocator(vm.addr(allocatorPrivateKey), address(theCompact)));

            // Register allocator and create lock tag
            uint96 allocatorId;
            bytes12 lockTag;
            (allocatorId, lockTag) = _registerAllocator(allocator);

            // Make deposit
            id = _makeDeposit(swapper, address(token), params.amount, lockTag);
        }

        // Create qualified digest and allocator signature
        bytes memory allocatorData;
        bytes32 qualificationArgument;
        bytes32 claimHash;
        {
            claimHash =
                _createClaimHash(compactTypehash, swapper, swapper, params.nonce, params.deadline, id, params.amount);

            qualificationArgument = keccak256("qualification");

            {
                bytes32 qualifiedDigest;
                {
                    bytes32 qualifiedHash = keccak256(
                        abi.encode(
                            keccak256("QualifiedClaim(bytes32 claimHash,bytes32 qualificationArg)"),
                            claimHash,
                            qualificationArgument
                        )
                    );

                    qualifiedDigest = _createDigest(theCompact.DOMAIN_SEPARATOR(), qualifiedHash);
                }

                bytes32 r;
                bytes32 vs;
                (r, vs) = vm.signCompact(allocatorPrivateKey, qualifiedDigest);
                allocatorData = abi.encodePacked(r, vs);
            }
        }

        // Prepare recipients
        Component[] memory recipients;
        {
            uint256 claimant = abi.decode(abi.encodePacked(bytes12(bytes32(id)), params.recipient), (uint256));

            Component memory split = Component({ claimant: claimant, amount: params.amount });

            recipients = new Component[](1);
            recipients[0] = split;
        }

        // Create and execute transfer
        bool status;
        {
            AllocatedTransfer memory transfer = AllocatedTransfer({
                nonce: params.nonce,
                expires: params.deadline,
                allocatorData: abi.encode(allocatorData, qualificationArgument),
                id: id,
                recipients: recipients
            });

            vm.prank(swapper);
            status = theCompact.allocatedTransfer(transfer);
            vm.snapshotGasLastCall("qualified_basicTransfer");
            assert(status);
        }

        // Verify balances
        {
            assertEq(token.balanceOf(address(theCompact)), params.amount);
            assertEq(token.balanceOf(params.recipient), 0);
            assertEq(theCompact.balanceOf(swapper, id), 0);
            assertEq(theCompact.balanceOf(params.recipient, id), params.amount);
        }
    }

    function test_splitWithdrawal() public {
        // Setup test parameters
        TestParams memory params;
        params.amount = 1e18;
        params.nonce = 0;
        params.deadline = block.timestamp + 1000;

        // Recipient information
        address recipientOne = 0x1111111111111111111111111111111111111111;
        address recipientTwo = 0x2222222222222222222222222222222222222222;
        uint256 amountOne = 4e17;
        uint256 amountTwo = 6e17;

        // Register allocator and create lock tag
        uint256 id;
        {
            (, bytes12 lockTag) = _registerAllocator(allocator);

            // Make deposit
            id = _makeDeposit(swapper, address(token), params.amount, lockTag);
        }

        // Create digest and allocator signature
        bytes memory allocatorData;
        {
            bytes32 digest;
            {
                bytes32 claimHash = _createClaimHash(
                    compactTypehash, swapper, swapper, params.nonce, params.deadline, id, params.amount
                );

                digest = _createDigest(theCompact.DOMAIN_SEPARATOR(), claimHash);
            }

            bytes32 r;
            bytes32 vs;
            (r, vs) = vm.signCompact(allocatorPrivateKey, digest);
            allocatorData = abi.encodePacked(r, vs);
        }

        // Prepare recipients
        Component[] memory recipients;
        {
            uint256 claimantOne;
            uint256 claimantTwo;
            {
                claimantOne = abi.decode(abi.encodePacked(bytes12(0), recipientOne), (uint256));
                claimantTwo = abi.decode(abi.encodePacked(bytes12(0), recipientTwo), (uint256));
            }

            {
                Component memory splitOne;
                Component memory splitTwo;

                splitOne = Component({ claimant: claimantOne, amount: amountOne });
                splitTwo = Component({ claimant: claimantTwo, amount: amountTwo });

                recipients = new Component[](2);
                recipients[0] = splitOne;
                recipients[1] = splitTwo;
            }
        }

        // Create and execute transfer
        {
            AllocatedTransfer memory transfer;
            {
                transfer = AllocatedTransfer({
                    nonce: params.nonce,
                    expires: params.deadline,
                    allocatorData: allocatorData,
                    id: id,
                    recipients: recipients
                });
            }

            {
                vm.prank(swapper);
                bool status = theCompact.allocatedTransfer(transfer);
                vm.snapshotGasLastCall("splitWithdrawal");
                assert(status);
            }
        }

        // Verify balances
        {
            assertEq(token.balanceOf(address(theCompact)), 0);
            assertEq(token.balanceOf(recipientOne), amountOne);
            assertEq(token.balanceOf(recipientTwo), amountTwo);
            assertEq(theCompact.balanceOf(swapper, id), 0);
            assertEq(theCompact.balanceOf(recipientOne, id), 0);
            assertEq(theCompact.balanceOf(recipientTwo, id), 0);
        }
    }

    function test_BatchTransfer() public {
        // Setup test parameters
        TestParams memory params;
        params.resetPeriod = ResetPeriod.TenMinutes;
        params.scope = Scope.Multichain;
        params.nonce = 0;
        params.deadline = block.timestamp + 1000;

        // Amount information
        uint256 amountOne = 1e18;
        uint256 amountTwo = 6e17;
        uint256 amountThree = 4e17;

        // Recipient information
        address recipientOne = 0x1111111111111111111111111111111111111111;
        address recipientTwo = 0x2222222222222222222222222222222222222222;

        // Register allocator and make deposits
        uint256 idOne;
        uint256 idTwo;
        {
            uint96 allocatorId;
            bytes12 lockTag;
            (allocatorId, lockTag) = _registerAllocator(allocator);

            idOne = _makeDeposit(swapper, address(token), amountOne, lockTag);
            idTwo = _makeDeposit(swapper, amountTwo + amountThree, lockTag);

            assertEq(theCompact.balanceOf(swapper, idOne), amountOne);
            assertEq(theCompact.balanceOf(swapper, idTwo), amountTwo + amountThree);
        }

        // Create idsAndAmounts array
        uint256[2][] memory idsAndAmounts;
        {
            idsAndAmounts = new uint256[2][](2);
            idsAndAmounts[0] = [idOne, amountOne];
            idsAndAmounts[1] = [idTwo, amountTwo + amountThree];
        }

        // Create digest and allocator signature
        bytes memory allocatorData;
        {
            bytes32 digest;
            {
                bytes32 batchCompactHash = keccak256(
                    abi.encode(
                        keccak256(
                            "BatchCompact(address arbiter,address sponsor,uint256 nonce,uint256 expires,uint256[2][] idsAndAmounts)"
                        ),
                        swapper,
                        swapper,
                        params.nonce,
                        params.deadline,
                        keccak256(abi.encodePacked(idsAndAmounts))
                    )
                );

                digest = _createDigest(theCompact.DOMAIN_SEPARATOR(), batchCompactHash);
            }

            bytes32 r;
            bytes32 vs;
            (r, vs) = vm.signCompact(allocatorPrivateKey, digest);
            allocatorData = abi.encodePacked(r, vs);
        }

        // Prepare transfers
        AllocatedBatchTransfer memory transfer;
        ComponentsById[] memory transfers = new ComponentsById[](2);
        {
            Component[] memory portionsOne;

            uint256 claimantOne = abi.decode(abi.encodePacked(bytes12(bytes32(idOne)), recipientOne), (uint256));

            portionsOne = new Component[](1);
            portionsOne[0] = Component({ claimant: claimantOne, amount: amountOne });

            transfers[0] = ComponentsById({ id: idOne, portions: portionsOne });
        }

        {
            Component[] memory portionsTwo;
            uint256 claimantTwo = abi.decode(abi.encodePacked(bytes12(bytes32(idTwo)), recipientOne), (uint256));
            uint256 claimantThree = abi.decode(abi.encodePacked(bytes12(bytes32(idTwo)), recipientTwo), (uint256));

            portionsTwo = new Component[](2);
            portionsTwo[0] = Component({ claimant: claimantTwo, amount: amountTwo });
            portionsTwo[1] = Component({ claimant: claimantThree, amount: amountThree });

            transfers[1] = ComponentsById({ id: idTwo, portions: portionsTwo });
        }

        {
            // Create batch transfer
            transfer = AllocatedBatchTransfer({
                nonce: params.nonce,
                expires: params.deadline,
                allocatorData: allocatorData,
                transfers: transfers
            });
        }

        // Execute transfer
        {
            vm.prank(swapper);
            bool status = theCompact.allocatedBatchTransfer(transfer);
            vm.snapshotGasLastCall("BatchTransfer");
            assert(status);
        }

        // Verify balances
        assertEq(token.balanceOf(recipientOne), 0);
        assertEq(token.balanceOf(recipientTwo), 0);
        assertEq(theCompact.balanceOf(swapper, idOne), 0);
        assertEq(theCompact.balanceOf(swapper, idTwo), 0);
        assertEq(theCompact.balanceOf(recipientOne, idOne), amountOne);
        assertEq(theCompact.balanceOf(recipientOne, idTwo), amountTwo);
        assertEq(theCompact.balanceOf(recipientTwo, idTwo), amountThree);
    }

    function test_splitBatchWithdrawal() public {
        // Setup test parameters
        TestParams memory params;
        params.resetPeriod = ResetPeriod.TenMinutes;
        params.scope = Scope.Multichain;
        params.nonce = 0;
        params.deadline = block.timestamp + 1000;

        // Amount information
        uint256 amountOne = 1e18;
        uint256 amountTwo = 6e17;
        uint256 amountThree = 4e17;

        // Recipient information
        address recipientOne = 0x1111111111111111111111111111111111111111;
        address recipientTwo = 0x2222222222222222222222222222222222222222;

        // Register allocator and make deposits
        uint256 idOne;
        uint256 idTwo;
        {
            uint96 allocatorId;
            bytes12 lockTag;
            (allocatorId, lockTag) = _registerAllocator(allocator);

            idOne = _makeDeposit(swapper, address(token), amountOne, lockTag);
            idTwo = _makeDeposit(swapper, amountTwo + amountThree, lockTag);

            assertEq(theCompact.balanceOf(swapper, idOne), amountOne);
            assertEq(theCompact.balanceOf(swapper, idTwo), amountTwo + amountThree);
        }

        // Create idsAndAmounts array
        uint256[2][] memory idsAndAmounts;
        {
            idsAndAmounts = new uint256[2][](2);
            idsAndAmounts[0] = [idOne, amountOne];
            idsAndAmounts[1] = [idTwo, amountTwo + amountThree];
        }

        // Create digest and allocator signature
        bytes memory allocatorData;
        {
            bytes32 digest;
            {
                bytes32 batchCompactHash = keccak256(
                    abi.encode(
                        keccak256(
                            "BatchCompact(address arbiter,address sponsor,uint256 nonce,uint256 expires,uint256[2][] idsAndAmounts)"
                        ),
                        swapper,
                        swapper,
                        params.nonce,
                        params.deadline,
                        keccak256(abi.encodePacked(idsAndAmounts))
                    )
                );

                digest = _createDigest(theCompact.DOMAIN_SEPARATOR(), batchCompactHash);
            }

            bytes32 r;
            bytes32 vs;
            (r, vs) = vm.signCompact(allocatorPrivateKey, digest);
            allocatorData = abi.encodePacked(r, vs);
        }

        // Prepare transfers
        AllocatedBatchTransfer memory transfer;
        ComponentsById[] memory transfers = new ComponentsById[](2);
        {
            // First transfer
            {
                Component[] memory portionsOne;
                uint256 claimantOne = abi.decode(abi.encodePacked(bytes12(0), recipientOne), (uint256));

                portionsOne = new Component[](1);
                portionsOne[0] = Component({ claimant: claimantOne, amount: amountOne });

                transfers[0] = ComponentsById({ id: idOne, portions: portionsOne });
            }

            // Second transfer
            {
                Component[] memory portionsTwo;
                uint256 claimantTwo = abi.decode(abi.encodePacked(bytes12(0), recipientOne), (uint256));
                uint256 claimantThree = abi.decode(abi.encodePacked(bytes12(0), recipientTwo), (uint256));

                portionsTwo = new Component[](2);
                portionsTwo[0] = Component({ claimant: claimantTwo, amount: amountTwo });
                portionsTwo[1] = Component({ claimant: claimantThree, amount: amountThree });

                transfers[1] = ComponentsById({ id: idTwo, portions: portionsTwo });
            }

            // Create batch transfer
            {
                transfer = AllocatedBatchTransfer({
                    nonce: params.nonce,
                    expires: params.deadline,
                    allocatorData: allocatorData,
                    transfers: transfers
                });
            }
        }

        // Execute transfer
        {
            vm.prank(swapper);
            bool status = theCompact.allocatedBatchTransfer(transfer);
            vm.snapshotGasLastCall("splitBatchWithdrawal");
            assert(status);
        }

        // Verify balances
        assertEq(token.balanceOf(recipientOne), amountOne);
        assertEq(token.balanceOf(recipientTwo), 0);
        assertEq(recipientOne.balance, amountTwo);
        assertEq(recipientTwo.balance, amountThree);
        assertEq(theCompact.balanceOf(swapper, idOne), 0);
        assertEq(theCompact.balanceOf(swapper, idTwo), 0);
        assertEq(theCompact.balanceOf(recipientOne, idOne), 0);
        assertEq(theCompact.balanceOf(recipientOne, idTwo), 0);
        assertEq(theCompact.balanceOf(recipientTwo, idTwo), 0);
    }

    function test_registerAndClaim() public {
        Claim memory claim;
        claim.sponsor = swapper;
        claim.nonce = 0;
        claim.expires = block.timestamp + 1000;
        claim.allocatedAmount = 1e18;

        address arbiter = 0x2222222222222222222222222222222222222222;
        address recipientOne = 0x1111111111111111111111111111111111111111;
        address recipientTwo = 0x3333333333333333333333333333333333333333;
        uint256 amountOne = 4e17;
        uint256 amountTwo = 6e17;

        {
            (, bytes12 lockTag) = _registerAllocator(allocator);

            claim.id = _makeDeposit(swapper, claim.allocatedAmount, lockTag);
            claim.witness = _createCompactWitness(234);
        }

        bytes32 claimHash;
        {
            CreateClaimHashWithWitnessArgs memory args;
            args.typehash = compactWithWitnessTypehash;
            args.arbiter = arbiter;
            args.sponsor = claim.sponsor;
            args.nonce = claim.nonce;
            args.expires = claim.expires;
            args.id = claim.id;
            args.amount = claim.allocatedAmount;
            args.witness = claim.witness;

            claimHash = _createClaimHashWithWitness(args);
        }

        bytes32 digest = _createDigest(theCompact.DOMAIN_SEPARATOR(), claimHash);

        {
            (bytes32 r, bytes32 vs) = vm.signCompact(allocatorPrivateKey, digest);
            claim.allocatorData = abi.encodePacked(r, vs);
        }

        uint256 claimantOne = abi.decode(abi.encodePacked(bytes12(bytes32(claim.id)), recipientOne), (uint256));
        uint256 claimantTwo = abi.decode(abi.encodePacked(bytes12(bytes32(claim.id)), recipientTwo), (uint256));

        Component[] memory recipients;
        {
            Component memory splitOne = Component({ claimant: claimantOne, amount: amountOne });

            Component memory splitTwo = Component({ claimant: claimantTwo, amount: amountTwo });

            recipients = new Component[](2);
            recipients[0] = splitOne;
            recipients[1] = splitTwo;
        }

        claim.sponsorSignature = "";
        claim.witnessTypestring = witnessTypestring;
        claim.claimants = recipients;

        vm.prank(swapper);
        {
            (bool status) = theCompact.register(claimHash, compactWithWitnessTypehash);
            vm.snapshotGasLastCall("register");
            assert(status);
        }

        {
            (bool isActive, uint256 registeredAt) =
                theCompact.getRegistrationStatus(swapper, claimHash, compactWithWitnessTypehash);
            assert(isActive);
            assertEq(registeredAt, block.timestamp);
        }

        vm.prank(arbiter);
        (bytes32 returnedClaimHash) = theCompact.claim(claim);
        vm.snapshotGasLastCall("claim");
        assertEq(returnedClaimHash, claimHash);

        assertEq(address(theCompact).balance, claim.allocatedAmount);
        assertEq(recipientOne.balance, 0);
        assertEq(recipientTwo.balance, 0);
        assertEq(theCompact.balanceOf(swapper, claim.id), 0);
        assertEq(theCompact.balanceOf(recipientOne, claim.id), amountOne);
        assertEq(theCompact.balanceOf(recipientTwo, claim.id), amountTwo);
    }

    function test_registerForAndClaim() public {
        // Setup test parameters
        TestParams memory params;
        params.resetPeriod = ResetPeriod.TenMinutes;
        params.scope = Scope.Multichain;
        params.amount = 1e18;
        params.nonce = 0;
        params.deadline = block.timestamp + 1000;
        params.recipient = 0x1111111111111111111111111111111111111111;

        // Additional parameters
        address arbiter = 0x2222222222222222222222222222222222222222;
        address swapperSponsor = makeAddr("swapperSponsor");

        // Register allocator and setup tokens
        uint256 id;
        bytes12 lockTag;
        {
            uint96 allocatorId;
            (allocatorId, lockTag) = _registerAllocator(allocator);

            vm.prank(swapper);
            token.transfer(swapperSponsor, params.amount);

            vm.prank(swapperSponsor);
            token.approve(address(theCompact), params.amount);
        }

        // Create witness and deposit/register
        bytes32 registeredClaimHash;
        bytes32 witness;
        uint256 witnessArgument = 234;
        {
            witness = keccak256(abi.encode(witnessArgument));

            vm.prank(swapperSponsor);
            (id, registeredClaimHash,) = theCompact.depositERC20AndRegisterFor(
                address(swapper),
                address(token),
                lockTag,
                params.amount,
                arbiter,
                params.nonce,
                params.deadline,
                compactWithWitnessTypehash,
                witness
            );
            vm.snapshotGasLastCall("depositRegisterFor");

            assertEq(theCompact.balanceOf(swapper, id), params.amount);
            assertEq(token.balanceOf(address(theCompact)), params.amount);
        }

        // Verify claim hash
        bytes32 claimHash;
        {
            CreateClaimHashWithWitnessArgs memory args;
            args.typehash = compactWithWitnessTypehash;
            args.arbiter = arbiter;
            args.sponsor = swapper;
            args.nonce = params.nonce;
            args.expires = params.deadline;
            args.id = id;
            args.amount = params.amount;
            args.witness = witness;

            claimHash = _createClaimHashWithWitness(args);
            assertEq(registeredClaimHash, claimHash);

            {
                bool isActive;
                uint256 registeredAt;
                (isActive, registeredAt) =
                    theCompact.getRegistrationStatus(swapper, claimHash, compactWithWitnessTypehash);
                assert(isActive);
                assertEq(registeredAt, block.timestamp);
            }
        }

        // Prepare claim
        Claim memory claim;
        {
            // Create digest and get allocator signature
            bytes memory allocatorSignature;
            {
                bytes32 digest = keccak256(abi.encodePacked(bytes2(0x1901), theCompact.DOMAIN_SEPARATOR(), claimHash));

                bytes32 r;
                bytes32 vs;
                (r, vs) = vm.signCompact(allocatorPrivateKey, digest);
                allocatorSignature = abi.encodePacked(r, vs);
            }

            // Create recipients
            Component[] memory recipients;
            {
                recipients = new Component[](1);

                uint256 claimantId = uint256(bytes32(abi.encodePacked(bytes12(bytes32(id)), params.recipient)));

                recipients[0] = Component({ claimant: claimantId, amount: params.amount });
            }

            // Build the claim
            claim = Claim(
                allocatorSignature,
                "", // sponsorSignature
                swapper,
                params.nonce,
                params.deadline,
                witness,
                witnessTypestring,
                id,
                params.amount,
                recipients
            );
        }

        // Execute claim
        {
            vm.prank(arbiter);
            bytes32 returnedClaimHash = theCompact.claim(claim);
            assertEq(returnedClaimHash, claimHash);
        }

        // Verify balances
        assertEq(token.balanceOf(address(theCompact)), params.amount);
        assertEq(theCompact.balanceOf(swapper, id), 0);
        assertEq(theCompact.balanceOf(params.recipient, id), params.amount);
    }

    function test_claimAndWithdraw() public {
        // Initialize claim struct
        Claim memory claim;
        claim.sponsor = swapper;
        claim.nonce = 0;
        claim.expires = block.timestamp + 1000;
        claim.allocatedAmount = 1e18;

        // Recipient information
        address recipientOne = 0x1111111111111111111111111111111111111111;
        address recipientTwo = 0x3333333333333333333333333333333333333333;
        uint256 amountOne = 4e17;
        uint256 amountTwo = 6e17;
        address arbiter = 0x2222222222222222222222222222222222222222;

        // Register allocator, make deposit and create witness
        {
            bytes12 lockTag;
            {
                uint96 allocatorId;
                (allocatorId, lockTag) = _registerAllocator(allocator);
            }

            claim.id = _makeDeposit(swapper, claim.allocatedAmount, lockTag);
            claim.witness = _createCompactWitness(234);
        }

        // Create claim hash
        bytes32 claimHash;
        {
            CreateClaimHashWithWitnessArgs memory args;
            args.typehash = compactWithWitnessTypehash;
            args.arbiter = arbiter;
            args.sponsor = claim.sponsor;
            args.nonce = claim.nonce;
            args.expires = claim.expires;
            args.id = claim.id;
            args.amount = claim.allocatedAmount;
            args.witness = claim.witness;

            claimHash = _createClaimHashWithWitness(args);
        }

        // Create signatures
        bytes32 digest = _createDigest(theCompact.DOMAIN_SEPARATOR(), claimHash);

        {
            bytes32 r;
            bytes32 vs;

            // Create sponsor signature
            {
                (r, vs) = vm.signCompact(swapperPrivateKey, digest);
                claim.sponsorSignature = abi.encodePacked(r, vs);
            }

            // Create allocator signature
            {
                (r, vs) = vm.signCompact(allocatorPrivateKey, digest);
                claim.allocatorData = abi.encodePacked(r, vs);
            }
        }

        // Prepare recipients
        {
            uint256 claimantOne = abi.decode(abi.encodePacked(bytes12(0), recipientOne), (uint256));
            uint256 claimantTwo = abi.decode(abi.encodePacked(bytes12(0), recipientTwo), (uint256));

            Component[] memory recipients;
            {
                Component memory splitOne = Component({ claimant: claimantOne, amount: amountOne });
                Component memory splitTwo = Component({ claimant: claimantTwo, amount: amountTwo });

                recipients = new Component[](2);
                recipients[0] = splitOne;
                recipients[1] = splitTwo;
            }

            claim.witnessTypestring = witnessTypestring;
            claim.claimants = recipients;
        }

        // Execute claim
        bytes32 returnedClaimHash;
        {
            vm.prank(arbiter);
            returnedClaimHash = theCompact.claim(claim);
            vm.snapshotGasLastCall("claimAndWithdraw");
            assertEq(returnedClaimHash, claimHash);
        }

        // Verify balances
        assertEq(address(theCompact).balance, 0);
        assertEq(recipientOne.balance, amountOne);
        assertEq(recipientTwo.balance, amountTwo);
        assertEq(theCompact.balanceOf(swapper, claim.id), 0);
        assertEq(theCompact.balanceOf(recipientOne, claim.id), 0);
        assertEq(theCompact.balanceOf(recipientTwo, claim.id), 0);
    }

    function test_depositAndRegisterWithWitnessViaPermit2ThenClaim() public virtual {
        // Setup test parameters
        TestParams memory params;
        params.resetPeriod = ResetPeriod.TenMinutes;
        params.scope = Scope.Multichain;
        params.amount = 1e18;
        params.nonce = 0;
        params.deadline = block.timestamp + 1000;

        // Initialize claim
        Claim memory claim;
        claim.sponsor = swapper;
        claim.nonce = params.nonce;
        claim.expires = block.timestamp + 1000;
        claim.allocatedAmount = params.amount;
        claim.witnessTypestring = witnessTypestring;
        claim.sponsorSignature = "";

        // Create domain separator
        bytes32 domainSeparator;
        {
            domainSeparator = keccak256(
                abi.encode(permit2EIP712DomainHash, keccak256(bytes("Permit2")), block.chainid, address(permit2))
            );
            assertEq(domainSeparator, EIP712(permit2).DOMAIN_SEPARATOR());
        }

        // Create witness and id
        LockDetails memory expectedDetails;
        uint96 allocatorId;
        {
            // Register allocator and setup
            bytes12 lockTag;
            {
                (allocatorId, lockTag) = _registerAllocator(allocator);
            }
            expectedDetails.lockTag = lockTag;

            uint256 witnessArgument = 234;
            claim.witness = _createCompactWitness(witnessArgument);
            claim.id = uint256(bytes32(lockTag)) | uint256(uint160(address(token)));
        }

        // Create claim hash
        bytes32 claimHash;
        {
            CreateClaimHashWithWitnessArgs memory args;
            args.typehash = compactWithWitnessTypehash;
            args.arbiter = 0x2222222222222222222222222222222222222222;
            args.sponsor = claim.sponsor;
            args.nonce = claim.nonce;
            args.expires = claim.expires;
            args.id = claim.id;
            args.amount = claim.allocatedAmount;
            args.witness = claim.witness;

            claimHash = _createClaimHashWithWitness(args);
        }

        // Create activation typehash and permit signature
        bytes memory signature;
        ISignatureTransfer.PermitTransferFrom memory permit;
        {
            bytes32 activationTypehash = keccak256(
                bytes(
                    string.concat("Activation(address activator,uint256 id,Compact compact)", compactWitnessTypestring)
                )
            );

            {
                bytes32 tokenPermissionsHash = keccak256(
                    abi.encode(
                        keccak256("TokenPermissions(address token,uint256 amount)"), address(token), params.amount
                    )
                );

                bytes32 permitWitnessHash;
                {
                    bytes32 activationHash =
                        keccak256(abi.encode(activationTypehash, address(1010), claim.id, claimHash));

                    permitWitnessHash = keccak256(
                        abi.encode(
                            keccak256(
                                "PermitWitnessTransferFrom(TokenPermissions permitted,address spender,uint256 nonce,uint256 deadline,Activation witness)Activation(address activator,uint256 id,Compact compact)Compact(address arbiter,address sponsor,uint256 nonce,uint256 expires,uint256 id,uint256 amount,Mandate mandate)Mandate(uint256 witnessArgument)TokenPermissions(address token,uint256 amount)"
                            ),
                            tokenPermissionsHash,
                            address(theCompact), // spender
                            params.nonce,
                            params.deadline,
                            activationHash
                        )
                    );
                }

                bytes32 digest = keccak256(abi.encodePacked(bytes2(0x1901), domainSeparator, permitWitnessHash));

                bytes32 r;
                bytes32 vs;
                (r, vs) = vm.signCompact(swapperPrivateKey, digest);
                signature = abi.encodePacked(r, vs);
            }

            // Create permit
            {
                permit = ISignatureTransfer.PermitTransferFrom({
                    permitted: ISignatureTransfer.TokenPermissions({ token: address(token), amount: params.amount }),
                    nonce: params.nonce,
                    deadline: params.deadline
                });
            }

            // Setup expectation for permitWitnessTransferFrom call
            {
                bytes32 activationHash = keccak256(abi.encode(activationTypehash, address(1010), claim.id, claimHash));

                vm.expectCall(
                    address(permit2),
                    abi.encodeWithSignature(
                        "permitWitnessTransferFrom(((address,uint256),uint256,uint256),(address,uint256),address,bytes32,string,bytes)",
                        permit,
                        ISignatureTransfer.SignatureTransferDetails({
                            to: address(theCompact),
                            requestedAmount: params.amount
                        }),
                        swapper,
                        activationHash,
                        "Activation witness)Activation(address activator,uint256 id,Compact compact)Compact(address arbiter,address sponsor,uint256 nonce,uint256 expires,uint256 id,uint256 amount,Mandate mandate)Mandate(uint256 witnessArgument)TokenPermissions(address token,uint256 amount)",
                        signature
                    )
                );
            }
        }

        // Deposit and register
        {
            vm.prank(address(1010));
            uint256 returnedId = theCompact.depositERC20AndRegisterViaPermit2(
                permit,
                swapper,
                expectedDetails.lockTag,
                claimHash,
                CompactCategory.Compact,
                witnessTypestring,
                signature
            );
            vm.snapshotGasLastCall("depositAndRegisterViaPermit2");
            assertEq(returnedId, claim.id);

            bool isActive;
            uint256 registeredAt;
            (isActive, registeredAt) = theCompact.getRegistrationStatus(swapper, claimHash, compactWithWitnessTypehash);
            assert(isActive);
            assertEq(registeredAt, block.timestamp);
        }

        // Verify lock details
        {
            expectedDetails.token = address(token);
            expectedDetails.allocator = allocator;
            expectedDetails.resetPeriod = params.resetPeriod;
            expectedDetails.scope = params.scope;

            _verifyLockDetails(claim.id, params, expectedDetails, allocatorId);

            assertEq(token.balanceOf(address(theCompact)), params.amount);
            assertEq(theCompact.balanceOf(swapper, claim.id), params.amount);
        }

        // Create allocator signature
        {
            bytes32 digest = _createDigest(theCompact.DOMAIN_SEPARATOR(), claimHash);

            bytes32 r;
            bytes32 vs;
            (r, vs) = vm.signCompact(allocatorPrivateKey, digest);
            claim.allocatorData = abi.encodePacked(r, vs);
        }

        uint256 amountOne = 4e17;
        uint256 amountTwo = 6e17;

        // Create split components
        {
            uint256 claimantOne = abi.decode(
                abi.encodePacked(bytes12(bytes32(claim.id)), 0x1111111111111111111111111111111111111111), (uint256)
            );
            uint256 claimantTwo = abi.decode(
                abi.encodePacked(bytes12(bytes32(claim.id)), 0x3333333333333333333333333333333333333333), (uint256)
            );

            Component[] memory recipients;
            {
                Component memory splitOne = Component({ claimant: claimantOne, amount: amountOne });
                Component memory splitTwo = Component({ claimant: claimantTwo, amount: amountTwo });

                recipients = new Component[](2);
                recipients[0] = splitOne;
                recipients[1] = splitTwo;

                claim.claimants = recipients;
            }
        }

        // Execute claim
        bytes32 returnedClaimHash;
        {
            vm.prank(0x2222222222222222222222222222222222222222);
            returnedClaimHash = theCompact.claim(claim);
            vm.snapshotGasLastCall("claim");
            assertEq(returnedClaimHash, claimHash);
        }

        // Verify balances
        assertEq(token.balanceOf(address(theCompact)), params.amount);
        assertEq(theCompact.balanceOf(swapper, claim.id), 0);
        assertEq(theCompact.balanceOf(0x1111111111111111111111111111111111111111, claim.id), amountOne);
        assertEq(theCompact.balanceOf(0x3333333333333333333333333333333333333333, claim.id), amountTwo);
    }

    function test_batchDepositAndRegisterWithWitnessViaPermit2ThenClaim() public virtual {
        // Setup test parameters
        TestParams memory params;
        params.resetPeriod = ResetPeriod.TenMinutes;
        params.scope = Scope.Multichain;
        params.nonce = 0;
        params.deadline = block.timestamp + 1000;

        // Initialize claim data
        BatchClaim memory claim;
        claim.sponsor = swapper;
        claim.nonce = params.nonce;
        claim.expires = block.timestamp + 1000;
        claim.witnessTypestring = witnessTypestring;

        // Register allocator and setup basic variables
        uint96 allocatorId;
        bytes12 lockTag;
        {
            (allocatorId, lockTag) = _registerAllocator(allocator);
        }

        // Create domain separator
        bytes32 domainSeparator;
        {
            domainSeparator = keccak256(
                abi.encode(permit2EIP712DomainHash, keccak256(bytes("Permit2")), block.chainid, address(permit2))
            );
            assertEq(domainSeparator, EIP712(permit2).DOMAIN_SEPARATOR());
        }

        // Create witness and typestring
        bytes32 typehash;
        {
            claim.witness = _createCompactWitness(234);

            string memory typestring =
                "BatchCompact(address arbiter,address sponsor,uint256 nonce,uint256 expires,uint256[2][] idsAndAmounts,Mandate mandate)Mandate(uint256 witnessArgument)";
            typehash = keccak256(bytes(typestring));
        }

        // Create ids and idsAndAmounts
        uint256[] memory ids;
        uint256[2][] memory idsAndAmounts;
        {
            uint256 id = (uint256(params.scope) << 255) | (uint256(params.resetPeriod) << 252)
                | (uint256(allocatorId) << 160) | uint256(uint160(address(0)));
            uint256 anotherId = (uint256(params.scope) << 255) | (uint256(params.resetPeriod) << 252)
                | (uint256(allocatorId) << 160) | uint256(uint160(address(token)));
            uint256 aThirdId = (uint256(params.scope) << 255) | (uint256(params.resetPeriod) << 252)
                | (uint256(allocatorId) << 160) | uint256(uint160(address(anotherToken)));

            ids = new uint256[](3);
            idsAndAmounts = new uint256[2][](3);

            ids[0] = id;
            ids[1] = anotherId;
            ids[2] = aThirdId;

            idsAndAmounts[0][0] = id;
            idsAndAmounts[0][1] = 1e18; // amount
            idsAndAmounts[1][0] = anotherId;
            idsAndAmounts[1][1] = 1e18; // anotherAmount
            idsAndAmounts[2][0] = aThirdId;
            idsAndAmounts[2][1] = 1e18; // aThirdAmount
        }

        // Create claim hash
        bytes32 claimHash;
        {
            CreateBatchClaimHashWithWitnessArgs memory args;
            {
                args.typehash = typehash;
                args.arbiter = 0x2222222222222222222222222222222222222222;
                args.sponsor = claim.sponsor;
                args.nonce = params.nonce;
                args.expires = claim.expires;
                args.idsAndAmountsHash = keccak256(abi.encodePacked(idsAndAmounts));
                args.witness = claim.witness;
            }

            claimHash = _createBatchClaimHashWithWitness(args);
        }

        // Create activation typehash
        bytes32 activationTypehash;
        {
            string memory typestring =
                "BatchCompact(address arbiter,address sponsor,uint256 nonce,uint256 expires,uint256[2][] idsAndAmounts,Mandate mandate)Mandate(uint256 witnessArgument)";
            activationTypehash = keccak256(
                bytes(
                    string.concat("BatchActivation(address activator,uint256[] ids,BatchCompact compact)", typestring)
                )
            );
        }

        // Create token permissions and signature
        ISignatureTransfer.TokenPermissions[] memory tokenPermissions;
        bytes memory signature;
        {
            tokenPermissions = new ISignatureTransfer.TokenPermissions[](3);
            tokenPermissions[0] = ISignatureTransfer.TokenPermissions({ token: address(0), amount: 1e18 });
            tokenPermissions[1] = ISignatureTransfer.TokenPermissions({ token: address(token), amount: 1e18 });
            tokenPermissions[2] = ISignatureTransfer.TokenPermissions({ token: address(anotherToken), amount: 1e18 });

            // Create signature
            {
                bytes32 tokenPermissionsHash;
                {
                    bytes32[] memory tokenPermissionsHashes = new bytes32[](2);

                    tokenPermissionsHashes[0] = keccak256(
                        abi.encode(keccak256("TokenPermissions(address token,uint256 amount)"), tokenPermissions[0])
                    );
                    tokenPermissionsHashes[0] = keccak256(
                        abi.encode(keccak256("TokenPermissions(address token,uint256 amount)"), tokenPermissions[1])
                    );
                    tokenPermissionsHashes[1] = keccak256(
                        abi.encode(keccak256("TokenPermissions(address token,uint256 amount)"), tokenPermissions[2])
                    );

                    tokenPermissionsHash = keccak256(abi.encodePacked(tokenPermissionsHashes));
                }

                bytes32 digest;
                {
                    CreatePermitBatchWitnessDigestArgs memory args;
                    {
                        args.domainSeparator = domainSeparator;
                        args.tokenPermissionsHash = tokenPermissionsHash;
                        args.spender = address(theCompact);
                        args.nonce = params.nonce;
                        args.deadline = params.deadline;
                        args.activationTypehash = activationTypehash;
                        args.idsHash = keccak256(abi.encodePacked(ids));
                        args.claimHash = claimHash;
                    }

                    digest = _createPermitBatchWitnessDigest(args);
                }

                bytes32 r;
                bytes32 vs;
                (r, vs) = vm.signCompact(swapperPrivateKey, digest);
                signature = abi.encodePacked(r, vs);
            }
        }

        {
            SetupPermitCallExpectationArgs memory args;
            args.activationTypehash = activationTypehash;
            args.ids = ids;
            args.claimHash = claimHash;
            args.nonce = params.nonce;
            args.deadline = params.deadline;
            args.signature = signature;

            _setupPermitCallExpectation(args);
        }

        // Deposit and register
        uint256[] memory returnedIds;
        {
            DepositDetails memory depositDetails;
            depositDetails.nonce = params.nonce;
            depositDetails.deadline = params.deadline;
            depositDetails.lockTag = lockTag;

            vm.prank(address(1010));
            vm.deal(address(1010), 1e18);
            returnedIds = theCompact.batchDepositAndRegisterViaPermit2{ value: 1e18 }(
                swapper,
                tokenPermissions,
                depositDetails,
                claimHash,
                CompactCategory.BatchCompact,
                witnessTypestring,
                signature
            );
            vm.snapshotGasLastCall("batchDepositAndRegisterWithWitnessViaPermit2");

            assertEq(returnedIds.length, 3);
            assertEq(returnedIds[0], ids[0]);
            assertEq(returnedIds[1], ids[1]);
            assertEq(returnedIds[2], ids[2]);

            assertEq(theCompact.balanceOf(swapper, ids[0]), 1e18);
            assertEq(theCompact.balanceOf(swapper, ids[1]), 1e18);
            assertEq(theCompact.balanceOf(swapper, ids[2]), 1e18);

            bool isActive;
            uint256 registeredAt;
            (isActive, registeredAt) = theCompact.getRegistrationStatus(swapper, claimHash, typehash);
            assert(isActive);
            assertEq(registeredAt, block.timestamp);
        }

        // Regenerate claim hash
        {
            CreateBatchClaimHashWithWitnessArgs memory args;
            {
                args.typehash = keccak256(
                    "BatchCompact(address arbiter,address sponsor,uint256 nonce,uint256 expires,uint256[2][] idsAndAmounts,Mandate mandate)Mandate(uint256 witnessArgument)"
                );
                args.arbiter = 0x2222222222222222222222222222222222222222;
                args.sponsor = swapper;
                args.nonce = params.nonce;
                args.expires = claim.expires;
                args.idsAndAmountsHash = keccak256(abi.encodePacked(idsAndAmounts));
                args.witness = claim.witness;
            }

            claimHash = _createBatchClaimHashWithWitness(args);
        }

        // Create signatures for claim
        {
            bytes32 digest = _createDigest(theCompact.DOMAIN_SEPARATOR(), claimHash);

            {
                bytes32 r;
                bytes32 vs;
                (r, vs) = vm.signCompact(swapperPrivateKey, digest);
                claim.sponsorSignature = abi.encodePacked(r, vs);
            }

            {
                bytes32 r;
                bytes32 vs;
                (r, vs) = vm.signCompact(allocatorPrivateKey, digest);
                claim.allocatorData = abi.encodePacked(r, vs);
            }
        }

        // Create claim components
        {
            BatchClaimComponent[] memory claims = new BatchClaimComponent[](3);
            {
                uint256 claimantOne = abi.decode(
                    abi.encodePacked(bytes12(bytes32(ids[0])), 0x1111111111111111111111111111111111111111), (uint256)
                );
                uint256 claimantTwo = abi.decode(
                    abi.encodePacked(bytes12(bytes32(ids[0])), 0x3333333333333333333333333333333333333333), (uint256)
                );
                uint256 claimantThree = abi.decode(
                    abi.encodePacked(bytes12(bytes32(ids[1])), 0x1111111111111111111111111111111111111111), (uint256)
                );
                uint256 claimantFour = abi.decode(
                    abi.encodePacked(bytes12(bytes32(ids[2])), 0x3333333333333333333333333333333333333333), (uint256)
                );

                {
                    Component[] memory portions = new Component[](2);
                    portions[0] = Component({ claimant: claimantOne, amount: 4e17 });
                    portions[1] = Component({ claimant: claimantTwo, amount: 6e17 });
                    claims[0] = BatchClaimComponent({ id: ids[0], allocatedAmount: 1e18, portions: portions });
                }

                {
                    Component[] memory anotherPortion = new Component[](1);
                    anotherPortion[0] = Component({ claimant: claimantThree, amount: 1e18 });
                    claims[1] = BatchClaimComponent({ id: ids[1], allocatedAmount: 1e18, portions: anotherPortion });
                }

                {
                    Component[] memory aThirdPortion = new Component[](1);
                    aThirdPortion[0] = Component({ claimant: claimantFour, amount: 1e18 });
                    claims[2] = BatchClaimComponent({ id: ids[2], allocatedAmount: 1e18, portions: aThirdPortion });
                }
            }

            claim.claims = claims;
        }

        // Execute claim
        bytes32 returnedClaimHash;
        {
            vm.prank(0x2222222222222222222222222222222222222222);
            returnedClaimHash = theCompact.batchClaim(claim);
            vm.snapshotGasLastCall("batchClaimRegisteredWithDepositWithWitness");
            assertEq(returnedClaimHash, claimHash);
        }

        // Verify balances
        assertEq(address(theCompact).balance, 1e18);
        assertEq(token.balanceOf(address(theCompact)), 1e18);
        assertEq(anotherToken.balanceOf(address(theCompact)), 1e18);

        assertEq(theCompact.balanceOf(0x1111111111111111111111111111111111111111, ids[0]), 4e17);
        assertEq(theCompact.balanceOf(0x3333333333333333333333333333333333333333, ids[0]), 6e17);
        assertEq(theCompact.balanceOf(0x1111111111111111111111111111111111111111, ids[1]), 1e18);
        assertEq(theCompact.balanceOf(0x3333333333333333333333333333333333333333, ids[2]), 1e18);
    }

    function test_splitClaimWithWitness() public {
        // Setup test parameters
        TestParams memory params;
        params.resetPeriod = ResetPeriod.TenMinutes;
        params.scope = Scope.Multichain;
        params.nonce = 0;
        params.deadline = block.timestamp + 1000;

        // Initialize claim
        Claim memory claim;
        claim.sponsor = swapper;
        claim.nonce = params.nonce;
        claim.expires = block.timestamp + 1000;
        claim.allocatedAmount = 1e18;
        claim.witnessTypestring = witnessTypestring;

        // Register allocator and make deposit
        {
            bytes12 lockTag;
            {
                uint96 allocatorId;
                (allocatorId, lockTag) = _registerAllocator(allocator);
            }

            claim.id = _makeDeposit(swapper, 1e18, lockTag);

            // Create witness
            uint256 witnessArgument = 234;
            claim.witness = _createCompactWitness(witnessArgument);
        }

        // Create claim hash
        bytes32 claimHash;
        {
            CreateClaimHashWithWitnessArgs memory args;
            {
                args.typehash = compactWithWitnessTypehash;
                args.arbiter = 0x2222222222222222222222222222222222222222;
                args.sponsor = claim.sponsor;
                args.nonce = claim.nonce;
                args.expires = claim.expires;
                args.id = claim.id;
                args.amount = claim.allocatedAmount;
                args.witness = claim.witness;
            }

            claimHash = _createClaimHashWithWitness(args);
        }

        // Create signatures
        {
            bytes32 digest = _createDigest(theCompact.DOMAIN_SEPARATOR(), claimHash);

            {
                bytes32 r;
                bytes32 vs;
                (r, vs) = vm.signCompact(swapperPrivateKey, digest);
                claim.sponsorSignature = abi.encodePacked(r, vs);
            }

            {
                bytes32 r;
                bytes32 vs;
                (r, vs) = vm.signCompact(allocatorPrivateKey, digest);
                claim.allocatorData = abi.encodePacked(r, vs);
            }
        }

        // Create split components
        {
            uint256 claimantOne = abi.decode(
                abi.encodePacked(bytes12(bytes32(claim.id)), 0x1111111111111111111111111111111111111111), (uint256)
            );
            uint256 claimantTwo = abi.decode(
                abi.encodePacked(bytes12(bytes32(claim.id)), 0x3333333333333333333333333333333333333333), (uint256)
            );

            Component[] memory recipients;
            {
                Component memory splitOne = Component({ claimant: claimantOne, amount: 4e17 });
                Component memory splitTwo = Component({ claimant: claimantTwo, amount: 6e17 });

                recipients = new Component[](2);
                recipients[0] = splitOne;
                recipients[1] = splitTwo;

                claim.claimants = recipients;
            }
        }

        // Execute claim
        bytes32 returnedClaimHash;
        {
            vm.prank(0x2222222222222222222222222222222222222222);
            returnedClaimHash = theCompact.claim(claim);
            vm.snapshotGasLastCall("splitClaimWithWitness");
            assertEq(returnedClaimHash, claimHash);
        }

        // Verify balances
        {
            assertEq(address(theCompact).balance, 1e18);
            assertEq(0x1111111111111111111111111111111111111111.balance, 0);
            assertEq(0x3333333333333333333333333333333333333333.balance, 0);
            assertEq(theCompact.balanceOf(swapper, claim.id), 0);

            assertEq(theCompact.balanceOf(0x1111111111111111111111111111111111111111, claim.id), 4e17);
            assertEq(theCompact.balanceOf(0x3333333333333333333333333333333333333333, claim.id), 6e17);
        }
    }

    function test_splitBatchClaimWithWitness() public {
        // Setup test parameters
        TestParams memory params;
        params.nonce = 0;
        params.deadline = block.timestamp + 1000;

        // Initialize batch claim
        BatchClaim memory claim;
        claim.sponsor = swapper;
        claim.nonce = params.nonce;
        claim.expires = block.timestamp + 1000;
        claim.witnessTypestring = witnessTypestring;

        // Register allocator and make deposits
        uint256 id;
        uint256 anotherId;
        uint256 aThirdId;
        {
            bytes12 lockTag;
            {
                uint96 allocatorId;
                (allocatorId, lockTag) = _registerAllocator(allocator);
            }

            id = _makeDeposit(swapper, 1e18, lockTag);
            anotherId = _makeDeposit(swapper, address(token), 1e18, lockTag);
            aThirdId = _makeDeposit(swapper, address(anotherToken), 1e18, lockTag);

            assertEq(theCompact.balanceOf(swapper, id), 1e18);
            assertEq(theCompact.balanceOf(swapper, anotherId), 1e18);
            assertEq(theCompact.balanceOf(swapper, aThirdId), 1e18);
        }

        // Create idsAndAmounts and witness
        uint256[2][] memory idsAndAmounts;
        {
            idsAndAmounts = new uint256[2][](3);
            idsAndAmounts[0] = [id, 1e18];
            idsAndAmounts[1] = [anotherId, 1e18];
            idsAndAmounts[2] = [aThirdId, 1e18];

            uint256 witnessArgument = 234;
            claim.witness = _createCompactWitness(witnessArgument);
        }

        // Create claim hash
        bytes32 claimHash;
        {
            CreateBatchClaimHashWithWitnessArgs memory args;
            {
                args.typehash = keccak256(
                    "BatchCompact(address arbiter,address sponsor,uint256 nonce,uint256 expires,uint256[2][] idsAndAmounts,Mandate mandate)Mandate(uint256 witnessArgument)"
                );
                args.arbiter = 0x2222222222222222222222222222222222222222;
                args.sponsor = claim.sponsor;
                args.nonce = claim.nonce;
                args.expires = claim.expires;
                args.idsAndAmountsHash = keccak256(abi.encodePacked(idsAndAmounts));
                args.witness = claim.witness;
            }

            claimHash = _createBatchClaimHashWithWitness(args);
        }

        // Create signatures
        {
            bytes32 digest = _createDigest(theCompact.DOMAIN_SEPARATOR(), claimHash);

            {
                bytes32 r;
                bytes32 vs;
                (r, vs) = vm.signCompact(swapperPrivateKey, digest);
                claim.sponsorSignature = abi.encodePacked(r, vs);
            }

            {
                bytes32 r;
                bytes32 vs;
                (r, vs) = vm.signCompact(allocatorPrivateKey, digest);
                claim.allocatorData = abi.encodePacked(r, vs);
            }
        }

        // Create batch claim components
        {
            BatchClaimComponent[] memory claims = new BatchClaimComponent[](3);

            // First claim component
            {
                uint256 claimantOne = abi.decode(
                    abi.encodePacked(bytes12(bytes32(id)), 0x1111111111111111111111111111111111111111), (uint256)
                );
                uint256 claimantTwo = abi.decode(
                    abi.encodePacked(bytes12(bytes32(id)), 0x3333333333333333333333333333333333333333), (uint256)
                );

                Component[] memory portions = new Component[](2);
                portions[0] = Component({ claimant: claimantOne, amount: 4e17 });
                portions[1] = Component({ claimant: claimantTwo, amount: 6e17 });

                claims[0] = BatchClaimComponent({ id: id, allocatedAmount: 1e18, portions: portions });
            }

            // Second claim component
            {
                uint256 claimantThree = abi.decode(
                    abi.encodePacked(bytes12(bytes32(anotherId)), 0x1111111111111111111111111111111111111111), (uint256)
                );

                Component[] memory anotherPortion = new Component[](1);
                anotherPortion[0] = Component({ claimant: claimantThree, amount: 1e18 });

                claims[1] = BatchClaimComponent({ id: anotherId, allocatedAmount: 1e18, portions: anotherPortion });
            }

            // Third claim component
            {
                uint256 claimantFour = abi.decode(
                    abi.encodePacked(bytes12(bytes32(aThirdId)), 0x3333333333333333333333333333333333333333), (uint256)
                );

                Component[] memory aThirdPortion = new Component[](1);
                aThirdPortion[0] = Component({ claimant: claimantFour, amount: 1e18 });

                claims[2] = BatchClaimComponent({ id: aThirdId, allocatedAmount: 1e18, portions: aThirdPortion });
            }

            claim.claims = claims;
        }

        // Execute claim
        bytes32 returnedClaimHash;
        {
            vm.prank(0x2222222222222222222222222222222222222222);
            returnedClaimHash = theCompact.batchClaim(claim);
            vm.snapshotGasLastCall("splitBatchClaimWithWitness");
            assertEq(returnedClaimHash, claimHash);
        }

        // Verify balances
        {
            assertEq(address(theCompact).balance, 1e18);
            assertEq(token.balanceOf(address(theCompact)), 1e18);
            assertEq(anotherToken.balanceOf(address(theCompact)), 1e18);

            assertEq(theCompact.balanceOf(0x1111111111111111111111111111111111111111, id), 4e17);
            assertEq(theCompact.balanceOf(0x3333333333333333333333333333333333333333, id), 6e17);
            assertEq(theCompact.balanceOf(0x1111111111111111111111111111111111111111, anotherId), 1e18);
            assertEq(theCompact.balanceOf(0x3333333333333333333333333333333333333333, aThirdId), 1e18);
        }
    }

    function test_splitMultichainClaimWithWitness() public {
        // Setup test parameters
        TestParams memory params;
        params.resetPeriod = ResetPeriod.TenMinutes;
        params.scope = Scope.Multichain;
        params.nonce = 0;
        params.deadline = block.timestamp + 1000;

        // Initialize multichain claim
        MultichainClaim memory claim;
        claim.sponsor = swapper;
        claim.nonce = params.nonce;
        claim.expires = params.deadline;
        claim.witnessTypestring = witnessTypestring;

        // Set up chain IDs
        uint256 anotherChainId = 7171717;
        uint256 thirdChainId = 41414141;

        // Register allocator and make deposits
        uint256 id;
        uint256 anotherId;
        {
            bytes12 lockTag;
            {
                uint96 allocatorId;
                (allocatorId, lockTag) = _registerAllocator(allocator);
            }

            id = _makeDeposit(swapper, 1e18, lockTag);
            anotherId = _makeDeposit(swapper, address(token), 1e18, lockTag);

            claim.id = id;
            claim.allocatedAmount = 1e18;
        }

        // Create ids and amounts arrays
        uint256[2][] memory idsAndAmountsOne;
        uint256[2][] memory idsAndAmountsTwo;
        {
            idsAndAmountsOne = new uint256[2][](1);
            idsAndAmountsOne[0] = [id, 1e18];

            idsAndAmountsTwo = new uint256[2][](1);
            idsAndAmountsTwo[0] = [anotherId, 1e18];
        }

        // Create witness
        {
            uint256 witnessArgument = 234;
            claim.witness = _createCompactWitness(witnessArgument);
        }

        // Create allocation hashes
        bytes32[] memory allocationHashes = new bytes32[](3);
        {
            bytes32 elementTypehash = keccak256(
                "Element(address arbiter,uint256 chainId,uint256[2][] idsAndAmounts,Mandate mandate)Mandate(uint256 witnessArgument)"
            );

            allocationHashes[0] = keccak256(
                abi.encode(
                    elementTypehash,
                    0x2222222222222222222222222222222222222222, // arbiter
                    block.chainid,
                    keccak256(abi.encodePacked(idsAndAmountsOne)),
                    claim.witness
                )
            );

            allocationHashes[1] = keccak256(
                abi.encode(
                    elementTypehash,
                    0x2222222222222222222222222222222222222222, // arbiter
                    anotherChainId,
                    keccak256(abi.encodePacked(idsAndAmountsTwo)),
                    claim.witness
                )
            );

            allocationHashes[2] = keccak256(
                abi.encode(
                    elementTypehash,
                    0x2222222222222222222222222222222222222222, // arbiter
                    thirdChainId,
                    keccak256(abi.encodePacked(idsAndAmountsTwo)),
                    claim.witness
                )
            );
        }

        // Create multichain claim hash
        bytes32 claimHash;
        {
            bytes32 multichainTypehash = keccak256(
                "MultichainCompact(address sponsor,uint256 nonce,uint256 expires,Element[] elements)Element(address arbiter,uint256 chainId,uint256[2][] idsAndAmounts,Mandate mandate)Mandate(uint256 witnessArgument)"
            );

            claimHash = keccak256(
                abi.encode(
                    multichainTypehash,
                    claim.sponsor,
                    claim.nonce,
                    claim.expires,
                    keccak256(abi.encodePacked(allocationHashes))
                )
            );
        }

        // Store initial domain separator
        bytes32 initialDomainSeparator = theCompact.DOMAIN_SEPARATOR();

        // Create signatures
        {
            bytes32 digest = _createDigest(initialDomainSeparator, claimHash);

            {
                bytes32 r;
                bytes32 vs;
                (r, vs) = vm.signCompact(swapperPrivateKey, digest);
                claim.sponsorSignature = abi.encodePacked(r, vs);
            }

            {
                bytes32 r;
                bytes32 vs;
                (r, vs) = vm.signCompact(allocatorPrivateKey, digest);
                claim.allocatorData = abi.encodePacked(r, vs);
            }
        }

        // Set up additional chains
        {
            bytes32[] memory additionalChains = new bytes32[](2);
            additionalChains[0] = allocationHashes[1];
            additionalChains[1] = allocationHashes[2];
            claim.additionalChains = additionalChains;
        }

        // Create split components
        {
            uint256 claimantOne = abi.decode(
                abi.encodePacked(bytes12(bytes32(id)), 0x1111111111111111111111111111111111111111), (uint256)
            );
            uint256 claimantTwo = abi.decode(
                abi.encodePacked(bytes12(bytes32(id)), 0x3333333333333333333333333333333333333333), (uint256)
            );

            Component[] memory recipients;
            {
                Component memory splitOne = Component({ claimant: claimantOne, amount: 4e17 });
                Component memory splitTwo = Component({ claimant: claimantTwo, amount: 6e17 });

                recipients = new Component[](2);
                recipients[0] = splitOne;
                recipients[1] = splitTwo;
            }

            claim.claimants = recipients;
        }

        // Execute claim and verify - first part
        {
            uint256 snapshotId = vm.snapshotState();

            {
                vm.prank(0x2222222222222222222222222222222222222222);
                bytes32 returnedClaimHash = theCompact.multichainClaim(claim);
                vm.snapshotGasLastCall("splitMultichainClaimWithWitness");
                assertEq(returnedClaimHash, claimHash);

                assertEq(address(theCompact).balance, 1e18);
                assertEq(0x1111111111111111111111111111111111111111.balance, 0);
                assertEq(0x3333333333333333333333333333333333333333.balance, 0);
                assertEq(theCompact.balanceOf(0x1111111111111111111111111111111111111111, id), 4e17);
                assertEq(theCompact.balanceOf(0x3333333333333333333333333333333333333333, id), 6e17);
            }

            vm.revertToAndDelete(snapshotId);
        }

        // Change to "new chain" and execute exogenous claim
        {
            // Save current chain ID and switch to another
            uint256 notarizedChainId = abi.decode(abi.encode(block.chainid), (uint256));
            vm.chainId(anotherChainId);
            assertEq(block.chainid, anotherChainId);

            // Get new domain separator
            bytes32 anotherDomainSeparator = theCompact.DOMAIN_SEPARATOR();
            assert(initialDomainSeparator != anotherDomainSeparator);

            // Create exogenous allocator signature
            bytes memory exogenousAllocatorData;
            {
                bytes32 digest = _createDigest(anotherDomainSeparator, claimHash);

                bytes32 r;
                bytes32 vs;
                (r, vs) = vm.signCompact(allocatorPrivateKey, digest);
                exogenousAllocatorData = abi.encodePacked(r, vs);
            }

            // Set up exogenous claim
            ExogenousMultichainClaim memory anotherClaim;
            {
                bytes32[] memory additionalChains = new bytes32[](2);
                additionalChains[0] = allocationHashes[0];
                additionalChains[1] = allocationHashes[2];

                anotherClaim.allocatorData = exogenousAllocatorData;
                anotherClaim.sponsorSignature = claim.sponsorSignature;
                anotherClaim.sponsor = claim.sponsor;
                anotherClaim.nonce = claim.nonce;
                anotherClaim.expires = claim.expires;
                anotherClaim.witness = claim.witness;
                anotherClaim.witnessTypestring = claim.witnessTypestring;
                anotherClaim.additionalChains = additionalChains;
                anotherClaim.chainIndex = 0;
                anotherClaim.notarizedChainId = notarizedChainId; // Changed from exogenousChainId to notarizedChainId
                anotherClaim.id = anotherId;
                anotherClaim.allocatedAmount = 1e18;
                anotherClaim.claimants = claim.claimants;
            }

            // Execute exogenous claim
            {
                vm.prank(0x2222222222222222222222222222222222222222);
                bytes32 returnedClaimHash = theCompact.exogenousClaim(anotherClaim);
                vm.snapshotGasLastCall("exogenousSplitMultichainClaimWithWitness");
                assertEq(returnedClaimHash, claimHash);

                assertEq(theCompact.balanceOf(swapper, anotherId), 0);
                assertEq(theCompact.balanceOf(0x1111111111111111111111111111111111111111, anotherId), 4e17);
                assertEq(theCompact.balanceOf(0x3333333333333333333333333333333333333333, anotherId), 6e17);
            }

            // Change back to original chain
            vm.chainId(notarizedChainId);
            assertEq(block.chainid, notarizedChainId);
        }
    }

    function test_splitBatchMultichainClaimWithWitness() public {
        // Setup test parameters
        TestParams memory params;
        params.deadline = block.timestamp + 1000;

        // Initialize batch multichain claim
        BatchMultichainClaim memory claim;
        claim.sponsor = swapper;
        claim.nonce = 0;
        claim.expires = params.deadline;
        claim.witnessTypestring = witnessTypestring;

        // Set up chain IDs
        uint256 anotherChainId = 7171717;

        // Register allocator and make deposits
        uint256[] memory ids = new uint256[](3);
        {
            bytes12 lockTag;
            {
                uint96 allocatorId;
                (allocatorId, lockTag) = _registerAllocator(allocator);
            }

            ids[0] = _makeDeposit(swapper, 1e18, lockTag);
            ids[1] = _makeDeposit(swapper, address(token), 1e18, lockTag);
            assertEq(theCompact.balanceOf(swapper, ids[1]), 1e18);

            ids[2] = _makeDeposit(swapper, address(anotherToken), 1e18, lockTag);
            assertEq(theCompact.balanceOf(swapper, ids[2]), 1e18);

            vm.stopPrank();

            assertEq(theCompact.balanceOf(swapper, ids[0]), 1e18);
            assertEq(theCompact.balanceOf(swapper, ids[1]), 1e18);
            assertEq(theCompact.balanceOf(swapper, ids[2]), 1e18);
        }

        // Create idsAndAmounts arrays
        uint256[2][] memory idsAndAmountsOne;
        uint256[2][] memory idsAndAmountsTwo;
        {
            idsAndAmountsOne = new uint256[2][](1);
            idsAndAmountsOne[0] = [ids[0], 1e18];

            idsAndAmountsTwo = new uint256[2][](2);
            idsAndAmountsTwo[0] = [ids[1], 1e18];
            idsAndAmountsTwo[1] = [ids[2], 1e18];
        }

        // Create witness
        {
            uint256 witnessArgument = 234;
            claim.witness = _createCompactWitness(witnessArgument);
        }

        // Create allocation hashes
        bytes32 allocationHashOne;
        bytes32 allocationHashTwo;
        {
            bytes32 elementTypehash = keccak256(
                "Element(address arbiter,uint256 chainId,uint256[2][] idsAndAmounts,Mandate mandate)Mandate(uint256 witnessArgument)"
            );

            allocationHashOne = keccak256(
                abi.encode(
                    elementTypehash,
                    0x2222222222222222222222222222222222222222, // arbiter
                    block.chainid,
                    keccak256(abi.encodePacked(idsAndAmountsOne)),
                    claim.witness
                )
            );

            allocationHashTwo = keccak256(
                abi.encode(
                    elementTypehash,
                    0x2222222222222222222222222222222222222222, // arbiter
                    anotherChainId,
                    keccak256(abi.encodePacked(idsAndAmountsTwo)),
                    claim.witness
                )
            );
        }

        // Create additional chains
        {
            bytes32[] memory additionalChains = new bytes32[](1);
            additionalChains[0] = allocationHashTwo;
            claim.additionalChains = additionalChains;
        }

        // Create multichain claim hash
        bytes32 claimHash;
        {
            bytes32 multichainTypehash = keccak256(
                "MultichainCompact(address sponsor,uint256 nonce,uint256 expires,Element[] elements)Element(address arbiter,uint256 chainId,uint256[2][] idsAndAmounts,Mandate mandate)Mandate(uint256 witnessArgument)"
            );

            claimHash = keccak256(
                abi.encode(
                    multichainTypehash,
                    claim.sponsor,
                    claim.nonce,
                    claim.expires,
                    keccak256(abi.encodePacked(allocationHashOne, allocationHashTwo))
                )
            );
        }

        // Store initial domain separator
        bytes32 initialDomainSeparator = theCompact.DOMAIN_SEPARATOR();

        // Create signatures
        {
            bytes32 digest = _createDigest(theCompact.DOMAIN_SEPARATOR(), claimHash);

            {
                (bytes32 r, bytes32 vs) = vm.signCompact(swapperPrivateKey, digest);
                claim.sponsorSignature = abi.encodePacked(r, vs);
                (r, vs) = vm.signCompact(allocatorPrivateKey, digest);
                claim.allocatorData = abi.encodePacked(r, vs);
            }
        }

        // Create batch claim components
        BatchClaimComponent[] memory claims = new BatchClaimComponent[](1);
        {
            Component[] memory recipients = new Component[](2);
            {
                uint256 claimantOne = abi.decode(
                    abi.encodePacked(bytes12(bytes32(ids[0])), 0x1111111111111111111111111111111111111111), (uint256)
                );
                uint256 claimantTwo = abi.decode(
                    abi.encodePacked(bytes12(bytes32(ids[0])), 0x3333333333333333333333333333333333333333), (uint256)
                );

                Component memory splitOne = Component({ claimant: claimantOne, amount: 4e17 });
                Component memory splitTwo = Component({ claimant: claimantTwo, amount: 6e17 });

                recipients[0] = splitOne;
                recipients[1] = splitTwo;
            }
            claims[0] = BatchClaimComponent({ id: ids[0], allocatedAmount: 1e18, portions: recipients });
        }

        // Execute claim and verify - first part
        {
            uint256 snapshotId = vm.snapshotState();

            {
                claim.claims = claims;

                vm.prank(0x2222222222222222222222222222222222222222);
                bytes32 returnedClaimHash = theCompact.batchMultichainClaim(claim);
                vm.snapshotGasLastCall("splitBatchMultichainClaimWithWitness");
                assertEq(returnedClaimHash, claimHash);

                assertEq(address(theCompact).balance, 1e18);
                assertEq(0x1111111111111111111111111111111111111111.balance, 0);
                assertEq(0x3333333333333333333333333333333333333333.balance, 0);
                assertEq(theCompact.balanceOf(swapper, ids[0]), 0);
                assertEq(theCompact.balanceOf(0x1111111111111111111111111111111111111111, ids[0]), 4e17);
                assertEq(theCompact.balanceOf(0x3333333333333333333333333333333333333333, ids[0]), 6e17);
            }

            vm.revertToStateAndDelete(snapshotId);
        }

        // Change to "new chain" and execute exogenous claim
        {
            // Save current chain ID and switch to another
            uint256 notarizedChainId = abi.decode(abi.encode(block.chainid), (uint256));
            vm.chainId(anotherChainId);
            assertEq(block.chainid, anotherChainId);

            assert(initialDomainSeparator != theCompact.DOMAIN_SEPARATOR());

            // Prepare additional chains
            bytes32[] memory additionalChains = new bytes32[](1);
            additionalChains[0] = allocationHashOne;

            // Create new recipients for different IDs
            BatchClaimComponent[] memory newClaims = new BatchClaimComponent[](2);
            {
                // First claim component
                {
                    uint256 claimantOne = abi.decode(
                        abi.encodePacked(bytes12(bytes32(ids[1])), 0x1111111111111111111111111111111111111111),
                        (uint256)
                    );

                    Component[] memory anotherRecipient = new Component[](1);
                    anotherRecipient[0] = Component({ claimant: claimantOne, amount: 1e18 });

                    newClaims[0] =
                        BatchClaimComponent({ id: ids[1], allocatedAmount: 1e18, portions: anotherRecipient });
                }

                // Second claim component
                {
                    uint256 claimantOne = abi.decode(
                        abi.encodePacked(bytes12(bytes32(ids[2])), 0x1111111111111111111111111111111111111111),
                        (uint256)
                    );
                    uint256 claimantTwo = abi.decode(
                        abi.encodePacked(bytes12(bytes32(ids[2])), 0x3333333333333333333333333333333333333333),
                        (uint256)
                    );

                    Component[] memory aThirdPortion = new Component[](2);
                    aThirdPortion[0] = Component({ claimant: claimantOne, amount: 4e17 });
                    aThirdPortion[1] = Component({ claimant: claimantTwo, amount: 6e17 });

                    newClaims[1] = BatchClaimComponent({ id: ids[2], allocatedAmount: 1e18, portions: aThirdPortion });
                }
            }

            // Set up exogenous claim
            ExogenousBatchMultichainClaim memory anotherClaim;

            // Create exogenous allocator signature
            {
                bytes32 digest = _createDigest(theCompact.DOMAIN_SEPARATOR(), claimHash);
                (bytes32 r, bytes32 vs) = vm.signCompact(allocatorPrivateKey, digest);
                anotherClaim.allocatorData = abi.encodePacked(r, vs);
            }
            {
                anotherClaim.sponsorSignature = claim.sponsorSignature;
                anotherClaim.sponsor = claim.sponsor;
                anotherClaim.nonce = claim.nonce;
                anotherClaim.expires = claim.expires;
                anotherClaim.witness = claim.witness;
                anotherClaim.witnessTypestring = "uint256 witnessArgument";
                anotherClaim.additionalChains = additionalChains;
                anotherClaim.chainIndex = 0;
                anotherClaim.notarizedChainId = notarizedChainId;
                anotherClaim.claims = newClaims;
            }

            // Execute exogenous claim
            {
                vm.prank(0x2222222222222222222222222222222222222222);
                bytes32 returnedClaimHash = theCompact.exogenousBatchClaim(anotherClaim);
                vm.snapshotGasLastCall("exogenousSplitBatchMultichainClaimWithWitness");
                assertEq(returnedClaimHash, claimHash);
            }

            // Verify balances
            assertEq(theCompact.balanceOf(swapper, ids[1]), 0);
            assertEq(theCompact.balanceOf(0x1111111111111111111111111111111111111111, ids[1]), 1e18);
            assertEq(theCompact.balanceOf(0x1111111111111111111111111111111111111111, ids[2]), 4e17);
            assertEq(theCompact.balanceOf(0x3333333333333333333333333333333333333333, ids[2]), 6e17);

            // Change back to original chain
            vm.chainId(notarizedChainId);
            assertEq(block.chainid, notarizedChainId);
        }
    }

    function test_claimAndWithdraw_withEmissary() public {
        uint256 amount = 1e18;
        uint256 nonce = 0;
        uint256 expires = block.timestamp + 1000;
        address recipientOne = 0x1111111111111111111111111111111111111111;
        address recipientTwo = 0x3333333333333333333333333333333333333333;
        uint256 amountOne = 4e17;
        uint256 amountTwo = 6e17;
        address arbiter = 0x2222222222222222222222222222222222222222;

        (, bytes12 lockTag) = _registerAllocator(allocator);

        address emissary = address(new AlwaysOKEmissary());
        vm.prank(swapper);
        theCompact.assignEmissary(lockTag, emissary);

        uint256 id = _makeDeposit(swapper, amount, lockTag);

        bytes32 claimHash;
        bytes32 witness = _createCompactWitness(234);
        {
            CreateClaimHashWithWitnessArgs memory args;
            args.typehash = compactWithWitnessTypehash;
            args.arbiter = arbiter;
            args.sponsor = swapper;
            args.nonce = nonce;
            args.expires = expires;
            args.id = id;
            args.amount = amount;
            args.witness = witness;

            claimHash = _createClaimHashWithWitness(args);
        }

        Claim memory claim;
        {
            bytes32 digest = _createDigest(theCompact.DOMAIN_SEPARATOR(), claimHash);

            (bytes32 r, bytes32 vs) = vm.signCompact(swapperPrivateKey, digest);
            claim.sponsorSignature = hex"41414141414141414141";

            (r, vs) = vm.signCompact(allocatorPrivateKey, digest);
            claim.allocatorData = abi.encodePacked(r, vs);
        }

        {
            uint256 claimantOne = abi.decode(abi.encodePacked(bytes12(0), recipientOne), (uint256));
            uint256 claimantTwo = abi.decode(abi.encodePacked(bytes12(0), recipientTwo), (uint256));

            Component memory splitOne = Component({ claimant: claimantOne, amount: amountOne });

            Component memory splitTwo = Component({ claimant: claimantTwo, amount: amountTwo });

            Component[] memory recipients = new Component[](2);
            recipients[0] = splitOne;
            recipients[1] = splitTwo;

            claim.claimants = recipients;
        }

        claim.sponsor = swapper;
        claim.nonce = nonce;
        claim.expires = expires;
        claim.witness = witness;
        claim.witnessTypestring = witnessTypestring;
        claim.id = id;
        claim.allocatedAmount = amount;

        vm.prank(arbiter);
        (bytes32 returnedClaimHash) = theCompact.claim(claim);
        vm.snapshotGasLastCall("claimAndWithdraw");
        assertEq(returnedClaimHash, claimHash);

        assertEq(address(theCompact).balance, 0);
        assertEq(recipientOne.balance, amountOne);
        assertEq(recipientTwo.balance, amountTwo);
        assertEq(theCompact.balanceOf(swapper, id), 0);
        assertEq(theCompact.balanceOf(recipientOne, id), 0);
        assertEq(theCompact.balanceOf(recipientTwo, id), 0);
    }

    function test_standardTransfer() public {
        address recipient = 0x1111111111111111111111111111111111111111;
        uint256 amount = 1e18;

        (, bytes12 lockTag) = _registerAllocator(alwaysOKAllocator);

        uint256 id = _makeDeposit(swapper, amount, lockTag);

        assertEq(address(theCompact).balance, amount);
        assertEq(theCompact.balanceOf(swapper, id), amount);
        assertEq(theCompact.balanceOf(recipient, id), 0);

        vm.prank(swapper);
        bool status = theCompact.transfer(recipient, id, amount);
        assert(status);

        assertEq(address(theCompact).balance, amount);
        assertEq(theCompact.balanceOf(swapper, id), 0);
        assertEq(theCompact.balanceOf(recipient, id), amount);
    }

    function test_allocatorId_leadingZeroes() public pure {
        address allocator1 = address(0x00000000000018DF021Ff2467dF97ff846E09f48);
        uint8 compactFlag1 = IdLib.toCompactFlag(allocator1);
        assertEq(compactFlag1, 9);

        address allocator2 = address(0x0000000000000000000000000000000000000000);
        uint8 compactFlag2 = IdLib.toCompactFlag(allocator2);
        assertEq(compactFlag2, 15);

        address allocator3 = address(0x0009524d380Dd4D95dfB975C50DaF3343BC177D9);
        uint8 compactFlag3 = IdLib.toCompactFlag(allocator3);
        assertEq(compactFlag3, 0);

        address allocator4 = address(0x00002752B69c388ac734CF666fB335588AE92618);
        uint8 compactFlag4 = IdLib.toCompactFlag(allocator4);
        assertEq(compactFlag4, 1);
    }

    function test_fuzz_addressToCompactFlag(address a) public pure {
        uint256 leadingZeroes = _countLeadingZeroes(a);
        uint8 compactFlag = IdLib.toCompactFlag(a);

        /**
         * The full scoring formula is:
         *  - 0-3 leading zero nibbles: 0
         *  - 4-17 leading zero nibbles: number of leading zeros minus 3
         *  - 18+ leading zero nibbles: 15
         */
        if (leadingZeroes < 4) assertEq(compactFlag, 0);
        else if (leadingZeroes <= 18) assertEq(compactFlag, leadingZeroes - 3);
        else assertEq(compactFlag, 15);
    }
}
