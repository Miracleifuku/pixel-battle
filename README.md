# Pixel Battle

A decentralized pixel art canvas built on the Stacks blockchain where users can claim, color, and interact with pixels while earning rewards.

## Overview

Pixel Battle is a collaborative digital art platform where users can:
- Claim pixels on a 100x100 canvas
- Color their pixels using hex color codes
- Interact with other users' pixels
- Earn rewards when others interact with their pixels

## Smart Contract Features

- **Canvas Management**: 100x100 pixel grid with unique ownership
- **Pixel Operations**:
  - Claim unowned pixels
  - Update pixel colors
  - Interact with others' pixels
- **Economic Model**:
  - Claim Fee: 1000 microSTX per pixel
  - Interaction Reward: 100 microSTX per interaction
- **User Stats Tracking**:
  - Pixels owned
  - Total rewards earned
  - Interaction counts

## Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- [Stacks CLI](https://docs.stacks.co/references/stacks-cli) installed
- A Stacks wallet with testnet STX for testing

## Installation

1. Clone the repository:
```bash
git clone https://github.com/miracleifuku/pixel-battle
cd pixel-battle
```

2. Install dependencies:
```bash
clarinet install
```

## Contract Deployment

### Local Testing
```bash
# Start local Clarinet console
clarinet console

# Run tests
clarinet test
```

### Testnet Deployment
```bash
# Deploy to testnet
clarinet deploy --testnet
```

## Contract Functions

### Read-Only Functions

1. `get-pixel`
   - Parameters: `x: uint`, `y: uint`
   - Returns: Pixel data if exists
   ```clarity
   (contract-call? .pixel-battle get-pixel u5 u10)
   ```

2. `get-user-stats`
   - Parameters: `user: principal`
   - Returns: User statistics
   ```clarity
   (contract-call? .pixel-battle get-user-stats tx-sender)
   ```

### Public Functions

1. `claim-pixel`
   - Parameters: 
     - `x: uint`
     - `y: uint`
     - `color: (string-utf8 7)`
   - Cost: 1000 microSTX
   ```clarity
   (contract-call? .pixel-battle claim-pixel u5 u10 "#FF0000")
   ```

2. `update-pixel`
   - Parameters:
     - `x: uint`
     - `y: uint`
     - `new-color: (string-utf8 7)`
   ```clarity
   (contract-call? .pixel-battle update-pixel u5 u10 "#00FF00")
   ```

3. `interact-with-pixel`
   - Parameters:
     - `x: uint`
     - `y: uint`
   - Reward: 100 microSTX to pixel owner
   ```clarity
   (contract-call? .pixel-battle interact-with-pixel u5 u10)
   ```

## Error Codes

- `ERR_UNAUTHORIZED (u100)`: Unauthorized access attempt
- `ERR_INVALID_POSITION (u101)`: Position outside canvas bounds
- `ERR_PIXEL_OWNED (u102)`: Attempt to claim owned pixel
- `ERR_INSUFFICIENT_FUNDS (u103)`: Insufficient STX for operation

## Testing

Run the test suite:
```bash
clarinet test
```

Example test scenarios are included in the `/tests` directory.

## Security Considerations

- Position validation ensures coordinates are within bounds
- Ownership verification for pixel updates
- Protected withdrawal function for contract owner
- Safe STX transfer handling
- Input validation for coordinates and colors

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

Your Name - [@miracleifuku](https://twitter.com/miracleifuku)
Project Link: [https://github.com/miracleifuku/pixel-battle](https://github.com/miracleifuku/pixel-battle)

## Acknowledgments

- Inspired by r/place
- Built with Clarity and Stacks
- Thanks to the Stacks community for support and feedback