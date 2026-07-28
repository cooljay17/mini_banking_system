# Initial Database Setup

This document describes the initial database objects created for the **Core Banking Mini Project**.

The objective of this script is to establish the foundational schema required for implementing core banking operations such as customer management, account maintenance, branch management, and transaction logging.

---

# Database User

A dedicated database user is created to own all banking-related objects.

```sql
CREATE USER BTMS;
```

> **Schema Name:** `BTMS`

---

# Database Objects

The initial schema consists of the following database objects:

| Object | Purpose |
|---------|---------|
| CUSTOMER | Stores customer information |
| ACCOUNT_TYPE | Stores master data for account types |
| BRANCH | Stores branch details |
| ACCOUNT | Stores customer account information |
| TXN_LOG | Maintains transaction audit history |
| Indexes | Improves transaction lookup performance |

---

# Table Descriptions

## CUSTOMER

Stores customer profile information.

### Key Attributes

- Customer ID
- First Name
- Surname
- Address
- Phone Number
- Email
- PAN Number
- Aadhaar Number
- Customer Status
- Audit Columns

### Status Values

- ACTIVE
- BLOCKED

---

## ACCOUNT_TYPE

Master table containing supported account types.

Examples include:

- Savings
- Current
- Salary
- Fixed Deposit

This table allows new account types to be introduced without changing application logic.

---

## BRANCH

Stores banking branch information.

Each account belongs to a branch through the **BRANCH_CODE** foreign key.

---

## ACCOUNT

Stores customer account details.

### Relationships

- Customer → CUSTOMER
- Branch → BRANCH
- Account Type → ACCOUNT_TYPE

### Key Information

- Account Number
- Branch
- Customer
- Account Type
- Current Balance
- Account Status

### Status Values

- ACTIVE
- BLOCKED

---

## TXN_LOG

Stores every banking transaction for auditing purposes.

Each record captures:

- Transaction ID
- Timestamp
- Source Account
- Destination Account
- Transaction Type
- Amount
- Status
- Error Message (if any)

### Supported Transaction Types

- CREATE
- DEPOSIT
- WITHDRAW
- TRANSFER

### Transaction Status

- SUCCESS
- FAILED

---

# Relationships

```
CUSTOMER
    │
    │ 1
    │
    └───────────────< ACCOUNT >─────────────── BRANCH
                        │
                        │
                        │
                        ▼
                  ACCOUNT_TYPE

ACCOUNT
   │
   ├───────────────┐
   │               │
   ▼               ▼
TXN_LOG        TXN_LOG
(from account) (to account)
```

---

# Constraints

The schema makes use of:

- Primary Keys
- Foreign Keys
- CHECK Constraints
- Default Values

These constraints help ensure data integrity throughout the banking system.

---

# Default Values

Several tables automatically populate the `created_at` column using:

```sql
SYSDATE
```

This records the creation timestamp without requiring manual input.

---

# Indexes

To improve transaction history lookup performance, indexes are created on:

| Index | Column |
|---------|--------|
| idx_from_acct_id | from_acct_id |
| idx_to_acct_id | to_acct_id |

These indexes optimize searches involving account transaction history.

---

# Planned Enhancements

The following objects are planned for upcoming iterations:

- Database Sequences
- Stored Procedures
- Functions
- Packages
- Triggers
- Views
- Sample Data
- Reports

---

# Current Schema Summary

| Object Type | Count |
|-------------|------:|
| User | 1 |
| Tables | 5 |
| Indexes | 2 |


---

## Version

**Version:** 1.0

This represents the initial database structure for the Core Banking Mini Project. Future versions will introduce business logic, transaction processing, automation, and reporting capabilities.

---

# Database Evolution(As per 28 August 2026)

This part describes the major schema changes made during the development of the **Core Banking Mini Project**. As new business requirements emerged, the database design was refined to better represent real-world banking operations while maintaining data integrity and auditability.

---

# Overview

The initial database schema established the core entities required for banking operations:

- CUSTOMER
- ACCOUNT_TYPE
- BRANCH
- ACCOUNT
- TXN_LOG

As the project progressed, several enhancements were introduced to support additional business scenarios and improve the overall design.

---

# Customer Enhancements

## Added Customer Name Columns

The original `CUSTOMER` table stored only customer identification details.

To better represent customer information, the following columns were added:

- `FIRST_NAME`
- `SURNAME`

These fields were defined as mandatory (`NOT NULL`).

---

## Automatic Creation Timestamp

The `created_at` column was updated to use:

```sql
DEFAULT SYSDATE
```

This ensures every customer record automatically stores its creation timestamp.

---

# Account Enhancements

## Branch Relationship

The `ACCOUNT` table was updated to reference the `BRANCH` table through a foreign key.

This establishes the relationship:

```
Branch
    │
    └────── Account
```

Each account now belongs to a valid banking branch.

---

## Automatic Creation Timestamp

The `created_at` column now defaults to `SYSDATE`.

---

# Account Type Enhancements

The `ACCOUNT_TYPE` table was updated to automatically populate the creation timestamp using:

```sql
DEFAULT SYSDATE
```

---

# Transaction Log Redesign

The transaction log underwent the most significant redesign.

---

## Separation of Business Operation and Transaction Channel

Initially, the `txn_type` column stored values such as:

- UPI
- NEFT
- IMPS
- CASH

These values actually represented **transaction channels**, not business operations.

The schema was redesigned by separating these concepts into two independent columns.

### `txn_type`

Represents the banking operation.

Allowed values:

- DEPOSIT
- WITHDRAW
- TRANSFER

### `txn_channel`

Represents the payment channel.

Allowed values include:

- CASH
- ATM WITHDRAWAL
- UPI
- NEFT
- IMPS
- FUND TRANSFER
- INTEREST CREDIT

This redesign provides greater flexibility and simplifies reporting.

---

# Transaction Type Constraint Changes

The original check constraint on `txn_type` was removed.

A new check constraint was introduced to validate only supported banking operations.

Similarly, a separate check constraint was created for `txn_channel` to validate supported transaction channels.

---

# Foreign Key Changes

Originally, the transaction log maintained foreign key relationships for both:

- `from_acct_id`
- `to_acct_id`

These constraints were later removed.

## Reason

Certain business operations do not require both account references.

Examples include:

- Cash deposits
- Cash withdrawals
- Interest credit by the bank

Removing the foreign keys allows transaction records to support these scenarios while still preserving account identifiers for auditing purposes.

---

# Index Changes

Initially, indexes existed on:

- `from_acct_id`
- `to_acct_id`

These indexes were dropped during schema redesign.

The decision was made to reassess indexing strategy after completing all transaction-related procedures to avoid maintaining unnecessary indexes during development.

---

# Sequence Objects

Two sequences were introduced to generate unique identifiers.

## Account Sequence

```
SEQ_ACCOUNT_ID
```

Used to generate new account numbers.

---

## Transaction Sequence

```
SEQ_TXN_ID
```

Used to generate unique transaction IDs.

The transaction sequence was later restarted from **10001** to provide more realistic transaction numbering during testing.

---

# Audit Trail Improvements

The transaction log now captures both successful and failed transactions.

Each record stores:

- Transaction Type
- Transaction Channel
- Source Account
- Destination Account
- Status
- Error Message
- Timestamp

This enables complete auditing and troubleshooting of banking operations.

---

# Design Benefits

The schema evolution provides several advantages:

- Better separation of business operations and payment channels.
- Support for both cash and electronic transactions.
- Improved auditability.
- Greater flexibility for future banking features.
- Simplified PL/SQL business logic.
- More realistic banking data model.

---

# Current Database Objects

| Object | Status |
|---------|--------|
| CUSTOMER | ✅ |
| ACCOUNT_TYPE | ✅ |
| BRANCH | ✅ |
| ACCOUNT | ✅ |
| TXN_LOG | ✅ |
| SEQ_ACCOUNT_ID | ✅ |
| SEQ_TXN_ID | ✅ |

---

# Future Enhancements

Planned database enhancements include:

- Transfer Money Procedure
- Account Creation Procedure
- Interest Credit Procedure
- Database Triggers
- Reporting Views
- Additional indexes based on query performance
- Transaction archival strategy

---

## Version

**Schema Version:** 2.0

This version reflects the current database design after incorporating transaction logging improvements, sequence generation, schema refinements, and support for additional banking business scenarios.
