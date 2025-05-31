# Timber Supply Chain Tracking Smart Contract

A comprehensive blockchain-based solution for tracking timber from forest to consumer with integrated sustainability verification. This smart contract provides complete transparency and traceability throughout the timber supply chain while ensuring environmental compliance.

## Features

- **End-to-End Traceability**: Track timber batches from harvest to final delivery
- **Sustainability Verification**: Built-in certification tracking for environmental compliance
- **Ownership Management**: Secure ownership transfers with authorization controls
- **Status Tracking**: Real-time status updates throughout the supply chain
- **Complete History**: Immutable audit trail for every batch
- **Location Tracking**: Geographic tracking of timber movement

## Contract Overview

This smart contract manages timber batches through a four-stage supply chain:

1. **Harvested** (Status 1): Initial timber harvest from origin forest
2. **Processed** (Status 2): Timber processing at mills or facilities
3. **Shipped** (Status 3): Transportation and logistics phase
4. **Delivered** (Status 4): Final delivery to end customer

## Data Structures

### Timber Batch Record
Each timber batch contains:
- Origin forest location
- Harvest date (block height)
- Volume of timber
- Current ownership
- Sustainability certification status
- Current supply chain status
- Current location
- Historical transaction count

### Batch History
Complete audit trail including:
- Timestamp of each transaction
- Ownership transfers (from/to principals)
- Status changes
- Location updates

## Core Functions

### Administrative Functions

#### `create-timber-batch`
Creates a new timber batch in the system.

**Parameters:**
- `origin-forest` (string-ascii 50): Source forest location
- `volume` (uint): Timber volume
- `sustainability-certified` (bool): Environmental certification status
- `location` (string-ascii 50): Initial location

**Authorization:** Contract owner only

**Returns:** Unique batch ID

### Supply Chain Management

#### `transfer-batch`
Transfers ownership of a timber batch to a new owner.

**Parameters:**
- `batch-id` (uint): Unique batch identifier
- `new-owner` (principal): New owner's blockchain address
- `new-location` (string-ascii 50): Updated location

**Authorization:** Current batch owner only

#### `update-batch-status`
Updates the supply chain status of a timber batch.

**Parameters:**
- `batch-id` (uint): Unique batch identifier
- `new-status` (uint): New status (1-4)
- `location` (string-ascii 50): Current location

**Authorization:** Current batch owner only

### Query Functions

#### `get-batch-info`
Retrieves complete information for a specific batch.

#### `get-batch-history`
Gets specific historical record for a batch.

#### `get-batch-full-history`
Returns the total number of historical records for a batch.

#### `get-total-batches`
Returns the total number of batches created.

#### `is-batch-sustainable`
Checks if a batch has sustainability certification.

#### `get-current-owner`
Returns the current owner of a batch.

#### `get-batch-status`
Returns the current supply chain status of a batch.

#### `get-batch-location`
Returns the current location of a batch.

#### `batch-exists`
Verifies if a batch ID exists in the system.

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 100  | `err-owner-only` | Function restricted to contract owner |
| 101  | `err-not-found` | Batch ID not found |
| 102  | `err-unauthorized` | User not authorized for this action |
| 103  | `err-invalid-status` | Invalid status code provided |
| 104  | `err-invalid-input` | Invalid input parameters |
| 105  | `err-invalid-volume` | Invalid volume value |
| 106  | `err-empty-string` | Empty string parameter |

## Status Codes

- **1**: Harvested - Timber has been harvested from the forest
- **2**: Processed - Timber has been processed at facilities
- **3**: Shipped - Timber is in transit
- **4**: Delivered - Timber has reached final destination

## Input Validation

The contract includes comprehensive input validation:
- String parameters must be non-empty (max 50 characters)
- Volume must be greater than zero
- Status codes must be between 1-4
- Batch IDs must exist in the system
- Authorization checks for all state-changing operations

## Security Features

- **Owner-only batch creation**: Only the contract owner can create new batches
- **Ownership verification**: Only current owners can transfer or update batches
- **Input sanitization**: All inputs are validated before processing
- **Immutable history**: Historical records cannot be modified once created

## Use Cases

### Forest Management Companies
- Create timber batches upon harvest
- Track sustainability certifications
- Maintain harvest records

### Processing Facilities
- Receive timber batches from harvesters
- Update processing status
- Transfer to logistics providers

### Logistics Companies
- Track timber shipments
- Update location and status
- Transfer to final destinations

### Retailers & End Customers
- Verify timber origin and sustainability
- Access complete supply chain history
- Ensure compliance with environmental regulations

## Deployment Requirements

- Stacks blockchain network
- Clarity smart contract runtime
- Valid principal address for contract deployment

## Integration Guidelines

### For Developers
1. Deploy contract to Stacks blockchain
2. Initialize with appropriate owner principal
3. Integrate read-only functions for UI display
4. Implement proper error handling for all function calls

### For Supply Chain Partners
1. Obtain blockchain wallet/principal
2. Coordinate with contract owner for batch creation
3. Use transfer functions for ownership changes
4. Update status as timber moves through supply chain

## License

This smart contract is provided as-is for timber supply chain tracking purposes. Ensure compliance with local regulations and environmental standards when implementing.

## Support

For technical support or questions about implementation, please refer to the Stacks blockchain documentation and Clarity language specifications.