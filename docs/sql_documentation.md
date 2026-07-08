# Database Initialization

This document describes the initial database objects created for the **Core Banking Mini Project**.

The script creates the application schema, core business tables, relationships, and indexes that form the foundation of the banking system.

---

# Database Schema

Schema Name

```
BTMS
```

The project uses a dedicated database schema named **BTMS** to isolate all banking-related database objects.

```sql
CREATE USER BTMS;
```

---

# Database Objects

The initial database consists of four primary tables.

| Table | Description |
|--------|-------------|
| CUSTOMER | Stores customer information |
| ACCOUNT_TYPE | Stores different account categories |
| ACCOUNT | Stores customer bank accounts |
| TXN_LOG | Stores transaction audit history |

---

# CUSTOMER Table

Stores personal information about bank customers.

### Purpose

Each customer can own one or more bank accounts.

### Key Information

- Customer ID
- Address
- Phone Number
- Email
- PAN
- Aadhaar
- Customer Status
- Audit Columns

### Business Rules

- Customer ID is the Primary Key.
- PAN is mandatory.
- Aadhaar is mandatory.
- Status defaults to **ACTIVE**.
- Status can only be:
  - ACTIVE
  - BLOCKED

---

# ACCOUNT_TYPE Table

Stores the list of supported bank account types.

### Purpose

Provides a master table for account classifications.

Examples:

- Savings
- Current
- Salary
- Fixed Deposit

### Business Rules

- Account Type Code is the Primary Key.
- Referenced by the ACCOUNT table.

---

# ACCOUNT Table

Stores all customer bank accounts.

### Purpose

Represents every bank account maintained by the bank.

### Key Information

- Account Number
- Branch Code
- Customer
- Account Type
- Current Balance
- Status

### Relationships

- CUSTOMER → ACCOUNT
- ACCOUNT_TYPE → ACCOUNT

### Business Rules

- Each account belongs to one customer.
- Every account has one account type.
- Balance is mandatory.
- Status defaults to ACTIVE.
- Status values:
  - ACTIVE
  - BLOCKED

---

# TXN_LOG Table

Maintains the transaction audit trail.

### Purpose

Records every financial operation performed in the banking system.

Supported Transactions

- CREATE
- DEPOSIT
- WITHDRAW
- TRANSFER

### Information Stored

- Transaction ID
- Timestamp
- Source Account
- Destination Account
- Transaction Amount
- Transaction Status
- Error Message

### Business Rules

Transaction Status

- SUCCESS
- FAILED

Transaction Types

- CREATE
- DEPOSIT
- WITHDRAW
- TRANSFER

The table acts as an audit log for every banking transaction.

---

# Relationships

```
CUSTOMER
    │
    │ 1
    │
    └───────────────< ACCOUNT >────────────── ACCOUNT_TYPE
                          │
                          │
                          │
                    TXN_LOG
                (From Account)
                (To Account)
```

---

# Indexes

Two indexes are created to improve transaction history lookup performance.

| Index | Column |
|--------|---------|
| idx_from_acct_id | from_acct_id |
| idx_to_acct_id | to_acct_id |

These indexes optimize searches for outgoing and incoming transactions.

---

# Audit Columns

Most tables include standard audit fields.

| Column | Purpose |
|----------|----------|
| created_at | Record creation timestamp |
| last_modified_at | Last update timestamp |

These columns help maintain data history and support auditing.

---

# Current Database Architecture

```
BTMS Schema
│
├── CUSTOMER
│
├── ACCOUNT_TYPE
│
├── ACCOUNT
│
└── TXN_LOG
```

This forms the foundational schema for the Core Banking Mini Project. Future iterations will introduce PL/SQL packages, stored procedures, triggers, functions, and reporting queries to implement complete banking operations.
