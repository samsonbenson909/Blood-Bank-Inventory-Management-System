# Blood Bank Inventory Management System

A comprehensive blockchain-based blood bank management system built with Clarity smart contracts for secure, transparent, and efficient blood inventory tracking and distribution.

## Overview

This system provides a complete solution for blood bank operations including:

- **Blood Type Compatibility**: Automatic matching and allocation based on ABO/Rh compatibility rules
- **Expiration Management**: Real-time tracking with FIFO rotation to minimize waste
- **Emergency Distribution**: Priority allocation during critical shortages
- **Donor Screening**: Comprehensive eligibility verification and safety protocols
- **Safety Protocols**: Cross-contamination prevention and audit trails

## System Architecture

### Core Contracts

1. **blood-inventory.clar** - Main inventory management and blood unit tracking
2. **donor-registry.clar** - Donor registration, screening, and eligibility management
3. **compatibility-engine.clar** - Blood type compatibility matching and allocation logic
4. **emergency-system.clar** - Critical shortage management and priority distribution
5. **safety-protocols.clar** - Cross-contamination prevention and audit logging

### Key Features

#### Blood Type Compatibility
- Full ABO/Rh compatibility matrix implementation
- Universal donor/recipient identification
- Emergency compatibility overrides for critical situations

#### Inventory Management
- Real-time unit tracking with unique identifiers
- Automatic expiration date monitoring
- FIFO rotation system to minimize waste
- Batch tracking for quality control

#### Emergency Response
- Automatic shortage detection and alerts
- Priority allocation algorithms
- Emergency distribution protocols
- Critical patient management

#### Safety & Compliance
- Comprehensive donor screening protocols
- Cross-contamination prevention measures
- Complete audit trails for regulatory compliance
- Quality assurance checkpoints

## Blood Type Compatibility Matrix

| Recipient | Can Receive From |
|-----------|------------------|
| O- | O- (Universal Recipient for Plasma) |
| O+ | O-, O+ |
| A- | O-, A- |
| A+ | O-, O+, A-, A+ |
| B- | O-, B- |
| B+ | O-, O+, B-, B+ |
| AB- | O-, A-, B-, AB- |
| AB+ | All types (Universal Recipient) |

## Getting Started

### Prerequisites
- Clarinet CLI
- Node.js 18+
- Vitest for testing

### Installation

\`\`\`bash
# Clone the repository
git clone <repository-url>
cd blood-bank-system

# Install dependencies
npm install

# Run tests
npm test

# Deploy contracts
clarinet deploy
\`\`\`

### Usage

#### Register a Donor
```clarity
(contract-call? .donor-registry register-donor 
  "John Doe" 
  u25 
  "A+" 
  "2024-01-15")
