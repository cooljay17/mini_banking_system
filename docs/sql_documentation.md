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
