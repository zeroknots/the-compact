// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { AllocatorLib } from "./AllocatorLib.sol";
import { RegistrationLib } from "./RegistrationLib.sol";
import { HashLib } from "./HashLib.sol";
import { ResetPeriod } from "../types/ResetPeriod.sol";
import { ValidityLib } from "./ValidityLib.sol";
import { IdLib } from "./IdLib.sol";

import { ConstructorLogic } from "./ConstructorLogic.sol";

/**
 * @title RegistrationLogic
 * @notice Inherited contract implementing logic for registering compact claim hashes
 * and typehashes and querying for whether given claim hashes and typehashes have
 * been registered.
 */
contract RegistrationLogic is ConstructorLogic {
    using AllocatorLib for uint256[2][];
    using RegistrationLib for address;
    using RegistrationLib for bytes32;
    using RegistrationLib for bytes32[2][];
    using ValidityLib for address;
    using ValidityLib for bytes32;
    using IdLib for address;

    /**
     * @notice Internal function for registering a claim hash. The claim hash and its
     * associated typehash will remain valid until the shortest reset period of the
     * compact that the claim hash is derived from has elapsed.
     * @param sponsor   The account registering the claim hash.
     * @param claimHash A bytes32 hash derived from the details of the compact.
     * @param typehash  The EIP-712 typehash associated with the claim hash.
     */
    function _register(address sponsor, bytes32 claimHash, bytes32 typehash) internal {
        sponsor.registerCompact(claimHash, typehash);
    }

    /**
     * @notice Internal function for registering multiple claim hashes in a single call. Each
     * claim hash and its associated typehash will remain valid until the shortest reset period
     * of the respective compact that the claim hash is derived from has elapsed.
     * @param claimHashesAndTypehashes Array of [claimHash, typehash] pairs for registration.
     * @return                         Whether all claim hashes were successfully registered.
     */
    function _registerBatch(bytes32[2][] calldata claimHashesAndTypehashes) internal returns (bool) {
        return claimHashesAndTypehashes.registerBatchAsCaller();
    }

    function _registerFor(
        address sponsor,
        address token,
        bytes12 lockTag,
        uint256 amount,
        address arbiter,
        uint256 nonce,
        uint256 expires,
        bytes32 typehash,
        bytes32 witness,
        bytes calldata sponsorSignature
    ) internal returns (uint256 id, bytes32 claimHash) {
        // Derive resource lock ID using provided token, parameters, and allocator.
        id = token.excludingNative().toIdIfRegistered(lockTag);

        claimHash =
            HashLib.toFlatMessageHashWithWitness(sponsor, id, amount, arbiter, nonce, expires, typehash, witness);

        {
            // Initialize idsAndAmounts array.
            uint256[2][] memory idsAndAmounts = new uint256[2][](1);
            idsAndAmounts[0] = [id, amount];

            // TODO: support registering exogenous domain separators by passing notarized chainId?
            claimHash.hasValidSponsor(sponsor, sponsorSignature, _domainSeparator(), idsAndAmounts);
        }

        sponsor.registerCompact(claimHash, typehash);
    }

    function _registerBatchFor(
        address sponsor,
        uint256[2][] calldata idsAndAmounts,
        address arbiter,
        uint256 nonce,
        uint256 expires,
        bytes32 typehash,
        bytes32 witness,
        bytes calldata sponsorSignature
    ) internal returns (bytes32 claimHash) {
        idsAndAmounts.enforceConsistentAllocators();

        // Note: skips replacement of provided amounts as there are no corresponding deposits.
        claimHash = HashLib.toFlatBatchClaimWithWitnessMessageHash(
            sponsor, idsAndAmounts, arbiter, nonce, expires, typehash, witness, new uint256[](0)
        );

        // TODO: support registering exogenous domain separators by passing notarized chainId
        claimHash.hasValidSponsor(sponsor, sponsorSignature, _domainSeparator(), idsAndAmounts);

        sponsor.registerCompact(claimHash, typehash);
    }

    /**
     * @notice Internal view function for retrieving the expiration timestamp of a
     * registration.
     * @param sponsor   The account that registered the claim hash.
     * @param claimHash A bytes32 hash derived from the details of the compact.
     * @param typehash  The EIP-712 typehash associated with the claim hash.
     * @return registrationTimestamp The timestamp at which the registration was made.
     */
    function _getRegistrationStatus(address sponsor, bytes32 claimHash, bytes32 typehash)
        internal
        view
        returns (uint256 registrationTimestamp)
    {
        registrationTimestamp = sponsor.toRegistrationTimestamp(claimHash, typehash);
    }

    //// Registration of specific claims ////

    /**
     * @notice Internal function to register a claim with witness by its components.
     * @dev Constructs and registers the compact that consists exactly of the provided
     * arguments.
     * @param sponsor     Account that the claim should be registered for.
     * @param tokenId     Identifier for the associated token & lock.
     * @param amount      Claim's associated number of tokens.
     * @param arbiter     Account verifying and initiating the settlement of the claim.
     * @param nonce       Allocator replay protection nonce.
     * @param expires     Timestamp when the claim expires. Not to be confused with the reset
     * time of the compact.
     * @param typehash    Typehash of the entire compact. Including the subtypes of the
     * witness
     * @param witness     EIP712 structured hash of witness.
     */
    function _registerUsingClaimWithWitness(
        address sponsor,
        uint256 tokenId,
        uint256 amount,
        address arbiter,
        uint256 nonce,
        uint256 expires,
        bytes32 typehash,
        bytes32 witness
    ) internal returns (bytes32 claimhash) {
        claimhash =
            HashLib.toFlatMessageHashWithWitness(sponsor, tokenId, amount, arbiter, nonce, expires, typehash, witness);
        sponsor.registerCompact(claimhash, typehash);
    }

    /**
     * @notice Internal function to register a batch claim with witness by its components.
     * @dev Constructs and registers the compact that consists exactly of the provided
     * arguments.
     * @param sponsor       Account that the claim should be registered for.
     * @param idsAndAmounts Ids and amounts associated with the to be registered claim.
     * @param arbiter       Account verifying and initiating the settlement of the claim.
     * @param nonce         Nonce to register the claim at. The nonce is not checked to be
     * unspent
     * @param expires       Timestamp when the claim expires. Not to be confused with the
     * reset time of the compact.
     * @param typehash      Typehash of the entire compact. Including the subtypes of the
     * witness
     * @param witness       EIP712 structured hash of witness.
     * @param replacementAmounts An optional array of replacement amounts.
     */
    function _registerUsingBatchClaimWithWitness(
        address sponsor,
        uint256[2][] calldata idsAndAmounts,
        address arbiter,
        uint256 nonce,
        uint256 expires,
        bytes32 typehash,
        bytes32 witness,
        uint256[] memory replacementAmounts
    ) internal returns (bytes32 claimhash) {
        claimhash = HashLib.toFlatBatchClaimWithWitnessMessageHash(
            sponsor, idsAndAmounts, arbiter, nonce, expires, typehash, witness, replacementAmounts
        );
        sponsor.registerCompact(claimhash, typehash);
    }
}
