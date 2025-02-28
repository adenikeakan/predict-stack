# PredictStack: Decentralized Prediction Markets on Stacks

PredictStack is a decentralized prediction market protocol built on the Stacks blockchain that enables anyone to create, trade, and resolve markets on future events with Bitcoin-level security and settlement assurance.

![PredictStack Banner](https://via.placeholder.com/800x200?text=PredictStack)

## Overview

PredictStack allows users to:
- Create prediction markets on any verifiable outcome
- Trade positions using STX tokens
- Earn rewards for correct predictions
- Participate in oracle validation for honest outcome resolution
- Enjoy the security of Bitcoin settlement through Stacks

## Key Features

### 🌐 Decentralized Market Creation
Anyone can create a prediction market by defining the question, possible outcomes, and resolution criteria. Market creation requires a small STX deposit to ensure quality and prevent spam.

### 🔄 Trustless Trading
All trading positions are managed through Clarity smart contracts, ensuring transparent, non-custodial trading with no centralized intermediary.

### 🔮 Oracle-Based Resolution
Market outcomes are determined through a decentralized oracle system, where validators stake STX to attest to real-world outcomes, with economic incentives to report truthfully.

### 🔒 Bitcoin-Backed Security
By leveraging the Stacks blockchain, all market activity inherits the security and finality of Bitcoin, making PredictStack more secure than prediction markets on other chains.

### 💰 Automated Settlements
Once a market resolves, winners receive their rewards automatically through smart contract execution, with no need for manual claims or withdrawals.

## Technical Architecture

PredictStack consists of several key components:

1. **Market Factory Contract**: Creates and initializes new prediction markets
2. **Market Contract**: Handles trading, positions, and fund management for individual markets
3. **Oracle Contract**: Manages the resolution process through validator consensus
4. **Treasury Contract**: Handles protocol fees and incentives for ecosystem participants

## Smart Contract Structure

```
├── contracts/
│   ├── market-factory.clar     # Creates new prediction markets
│   ├── market.clar             # Individual market logic
│   ├── oracle-manager.clar     # Manages oracle validation process
│   ├── treasury.clar           # Fee management and distribution
│   └── lib/
│       ├── traits.clar         # Common contract traits
│       └── errors.clar         # Standardized error codes
```

## How It Works

1. **Market Creation**: A creator defines a market question, outcome options, and deadline
2. **Trading Period**: Users buy and sell outcome shares, with prices fluctuating based on market activity
3. **Resolution**: After the event occurs, oracle validators submit and verify the actual outcome
4. **Settlement**: Smart contracts automatically distribute rewards to users who predicted correctly

## Oracle System

PredictStack uses a decentralized oracle system with economic incentives:

- Validators stake STX to participate in outcome verification
- Multiple independent validators must reach consensus on outcomes
- Validators who report dishonestly lose their stakes
- Honest validators earn a portion of market fees

## Use Cases

- Political elections
- Sports outcomes
- Financial markets predictions
- Weather forecasts
- Technology product launches
- Entertainment (awards, movie performances)
- Scientific breakthroughs

## Getting Started

```bash
# Clone repository
git clone https://github.com/adenikeakan/predict-stack

# Install dependencies
npm install

# Run tests
npm test

# Deploy contracts (requires Clarinet)
clarinet console
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
