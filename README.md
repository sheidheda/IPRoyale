# IPRoyale: Intellectual Property Rights Management Contract

## Overview
**IPRoyale** is a Clarity-based smart contract for managing intellectual property (IP) rights. It allows creators to register IP assets, track ownership, issue licenses, and distribute royalties, providing a decentralized and transparent solution for IP management.

---

## Features
1. **IP Registration**: Register new IP assets with detailed metadata, including title, description, total shares, base price, and license type.
2. **Ownership Management**: Transfer IP ownership shares between users securely.
3. **Licensing**: Issue licenses with specific terms like usage limits, expiration, and royalty rates.
4. **Royalty Management**: Record usage and calculate royalties, with automated revenue distribution to IP owners.
5. **Revenue Tracking**: Track total and distributed revenue for each IP asset.

---

## Constants
- **CONTRACT-OWNER**: Defines the creator or owner of the contract.
- **Error Codes**:
  - `ERR-UNAUTHORIZED` (`u100`): Unauthorized access or action.
  - `ERR-INVALID-IP` (`u101`): Invalid IP asset ID.
  - `ERR-ALREADY-EXISTS` (`u102`): IP asset already registered.
  - `ERR-NOT-FOUND` (`u103`): IP asset or license not found.
  - `ERR-INSUFFICIENT-BALANCE` (`u104`): Insufficient balance for an operation.
  - `ERR-INVALID-INPUT` (`u105`): Invalid input data.

---

## Functions

### Public Functions

#### 1. `register-ip`
Registers a new IP asset.
- **Parameters**:
  - `title` (string-ascii, max 100 chars): IP title.
  - `description` (string-ascii, max 500 chars): IP description.
  - `total-shares` (uint): Total ownership shares for the IP.
  - `base-price` (uint): Base price for calculating royalties.
  - `license-type` (string-ascii, max 50 chars): Licensing terms.
- **Returns**: `ip-id` (uint): Unique identifier for the registered IP.

---

#### 2. `transfer-ip-shares`
Transfers ownership shares of an IP asset.
- **Parameters**:
  - `ip-id` (uint): Identifier of the IP.
  - `recipient` (principal): Recipient address.
  - `shares` (uint): Number of shares to transfer.
- **Returns**: `true` if successful.

---

#### 3. `issue-license`
Issues a license for an IP asset.
- **Parameters**:
  - `ip-id` (uint): Identifier of the IP.
  - `licensee` (principal): Licensee's address.
  - `license-type` (string-ascii, max 50 chars): Licensing type.
  - `usage-count` (uint): Allowed usage count.
  - `expiration` (uint): Expiration block height.
  - `royalty-rate` (uint): Royalty percentage.
- **Returns**: `true` if successful.

---

#### 4. `record-ip-usage`
Records usage of an IP asset and calculates royalties.
- **Parameters**:
  - `ip-id` (uint): Identifier of the IP.
  - `licensee` (principal): Address of the licensee.
- **Returns**: Royalty amount (uint).

---

#### 5. `distribute-royalties`
Distributes accumulated royalties to IP owners.
- **Parameters**:
  - `ip-id` (uint): Identifier of the IP.
- **Returns**: `true` if successful.

---

## Data Structures

1. **`ip-registry` (Map)**:
   Stores IP metadata such as creator, title, description, total shares, base price, and license type.

2. **`ip-ownership` (Map)**:
   Tracks ownership shares of an IP asset per user.

3. **`ip-licenses` (Map)**:
   Manages issued licenses with terms like usage count, expiration, and royalty rate.

4. **`ip-revenue` (Map)**:
   Tracks total and distributed revenue for IP assets.

---

## Input Validation
Private helper functions ensure that all input data meets predefined criteria, such as non-zero lengths for strings and positive values for numbers.

---

## Deployment
This contract is written in Clarity and is compatible with the Stacks blockchain. Deploy the contract using Clarity-compatible development tools.

---

## Future Enhancements
1. **Automated Royalty Distribution**: Implement logic for proportional revenue distribution to IP owners.
2. **IP Asset Search**: Add querying capabilities for IP metadata.
3. **Dynamic Pricing**: Allow updates to base price based on market demand.

---

**Disclaimer**: This contract is for educational and experimental purposes. Use in production environments is at your own risk.