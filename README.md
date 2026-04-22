# PROJECT NAME: ICO v2 Modular Token Sale Protocol

A production-grade ICO protocol engineered with multi-phase token distribution, signature-based KYC gating, referral incentives, and oracle-driven pricing. Designed with security, extensibility, and real-world deployment constraints in mind.

---

## PROBLEM STATMENT

ICO v2 is a token sale system that abstracts core ICO primitives such as pricing strategies, participant validation, and reward distribution into composable components.

The protocol is designed to address common shortcomings in legacy ICO implementations:
- Static pricing models
- Weak identity verification
- Lack of incentive alignment
- Poor security practices

---

## Core Architecture

The system follows a layered design:

-     Participant Layer ↓ Validation Layer (KYC / Signature Verification) ↓ Sale Engine (Round-based Pricing) ↓ Reward Engine (Referral Logic) ↓ Oracle Layer (External Price Feeds)

Each layer is isolated to ensure maintainability and upgradeability.

---

## Tech Stack
Solidity
Hardhat
ethers.js
OpenZeppelin
Chainlink

---

## Key Components

### 1. Sale Engine
- Supports multi-phase token distribution (Seed / Private / Public)
- Dynamic pricing per round
- Time-based or supply-based transitions
- Designed for flexible extension (e.g., Dutch auction)

---

### 2. Signature-Based KYC Module
- Off-chain identity verification
- On-chain validation using ECDSA signatures
- Nonce-based replay protection

---

### 3. Signature-Based KYC Module
- Tracks referral relationships on-chain
- Reward distribution logic embedded in purchase flow
- Designed to prevent abuse and circular referrals

---

### 4. Oracle Integration
- Integrates external pricing using Chainlink feeds
- Enables real-time token valuation against native currency
- Reduces pricing manipulation risk

---

### 5. Access Control Layer
- Role-based permissions using AccessControl
- Separation between admin, operator, and signer roles
- Minimizes privilege escalation risk

---

### Security Design
Security is treated as a first-class concern:

Replay Attack Prevention: Nonce-based signature validation ensures one-time authorization
Access Isolation: Role-based control prevents unauthorized state changes
Input Validation: Strict checks on user inputs and external calls
Deterministic Pricing Logic: Eliminates inconsistencies across sale rounds

---

### Testing Strategy
Unit tests written using Hardhat + Mocha
Coverage includes:
Signature validation failures
Round transition logic
Referral reward correctness
Access control enforcement

---

### Gas & Optimization Considerations
Minimized storage writes in critical paths
Efficient struct packing for sale configurations
Reduced redundant oracle calls
Extensibility

---

### ICO v3 upgrades:
Vesting module (cliff + linear unlock)
Soft cap / hard cap enforcement with refunds
Stablecoin support (USDT / USDC)
DAO-controlled sale parameters
Upgradeable proxy pattern (optional)


