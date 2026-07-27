# Package Documentation - `PKG_BANKING_SYSTEM`

## Overview

`PKG_BANKING_SYSTEM` is the primary PL/SQL package for the **Core Banking Mini Project**. It encapsulates banking business logic and provides reusable procedures and functions for account-related operations.

The package is designed to:

- Centralize banking business logic
- Validate business rules before updating data
- Maintain transaction history
- Handle exceptions gracefully
- Ensure transactional consistency

---

# Package Specification

The package currently exposes the following public interfaces:

| Object | Type | Description |
|---------|------|-------------|
| `get_account_balance` | Function | Returns the current balance of an active account |
| `deposit_money` | Procedure | Deposits money into an account after validating business rules |

---

# Package Components

```
PKG_BANKING_SYSTEM
│
├── get_account_balance()
│
└── deposit_money()
```

---

# Function: `get_account_balance`

## Purpose

Returns the current balance of a customer account after verifying that the account exists and is active.

---

## Syntax

```plsql
FUNCTION get_account_balance(
    p_account_id IN ACCOUNT.account_id%TYPE
)
RETURN NUMBER;
```

---

## Input Parameters

| Parameter | Description |
|-----------|-------------|
| `p_account_id` | Account whose balance needs to be retrieved |

---

## Returns

| Return Value | Description |
|-------------|-------------|
| Balance | Current account balance |
| NULL | Account not found or account is blocked |

---

## Business Rules

- Account must exist.
- Account status must be **ACTIVE**.
- Blocked accounts cannot retrieve balances.
- Returns `NULL` when validation fails.

---

## Exception Handling

| Exception | Description |
|-----------|-------------|
| `NO_DATA_FOUND` | Account does not exist |
| `inactive_account` | Account is blocked |
| `OTHERS` | Unexpected database error |

---

# Procedure: `deposit_money`

## Purpose

Deposits money into an account while validating banking rules and recording the transaction in the audit log.

---

## Syntax

```plsql
PROCEDURE deposit_money(
    p_from_account_id IN VARCHAR2 DEFAULT NULL,
    p_to_account_id   IN ACCOUNT.account_id%TYPE,
    p_txn_channel     IN TXN_LOG.txn_channel%TYPE,
    p_amount          IN NUMBER
);
```

---

## Input Parameters

| Parameter | Description |
|-----------|-------------|
| `p_from_account_id` | Source account (optional for cash deposits) |
| `p_to_account_id` | Destination account |
| `p_txn_channel` | Deposit channel (Cash, UPI, NEFT, etc.) |
| `p_amount` | Deposit amount |

---

# Supported Deposit Channels

The procedure currently supports the following deposit channels:

- CASH
- UPI
- NEFT
- IMPS
- FUND TRANSFER
- INTEREST CREDIT

---

# Business Rules

The procedure performs the following validations before updating account balances.

## 1. Destination account must exist

The account is validated using the `get_account_balance()` function.

---

## 2. Destination account must be ACTIVE

Blocked accounts are not allowed to receive deposits.

---

## 3. Deposit amount must be greater than zero

Zero or negative deposits are rejected.

---

## 4. Cash deposits

When the transaction channel is **CASH**, the source account is optional.

Example:

```
Channel : CASH

From Account : NULL

Allowed ✔
```

---

## 5. Non-cash deposits

For all electronic transaction channels, the source account is mandatory.

Example:

```
Channel : UPI

From Account : NULL

Rejected ✘
```

---

# Processing Flow

```
Start
   │
   ▼
Validate destination account
   │
   ▼
Check account status
   │
   ▼
Validate deposit amount
   │
   ▼
Validate source account
(for non-cash deposits)
   │
   ▼
Lock destination account
(FOR UPDATE)
   │
   ▼
Update account balance
   │
   ▼
Insert SUCCESS transaction log
   │
   ▼
Commit
```

---

# Transaction Management

To avoid concurrent update issues, the destination account row is explicitly locked before updating.

```sql
SELECT ...
FOR UPDATE;
```

This ensures that:

- Two sessions cannot update the same account simultaneously.
- Account balances remain consistent.

---

# Transaction Logging

Every execution of the procedure generates a record in the `TXN_LOG` table.

Successful transactions include:

- Transaction ID
- Source account
- Destination account
- Transaction Type
- Transaction Channel
- Amount
- Status

Failed transactions additionally record:

- Error message
- Failed amount

This provides a complete audit trail.

---

# Exception Handling

The procedure handles both business and database exceptions.

## Custom Exceptions

| Exception | Description |
|-----------|-------------|
| `zero_deposit_amount` | Deposit amount is zero or negative |
| `inactive_account` | Destination account is blocked |
| `empty_from_account_id` | Source account missing for non-cash deposits |

---

## Oracle Exception

| Exception | Description |
|-----------|-------------|
| `e_check_constraint_violation` | Raised when CHECK constraints are violated (`ORA-02290`) |

The package maps the Oracle error using:

```plsql
PRAGMA EXCEPTION_INIT(
    e_check_constraint_violation,
    -2290
);
```

---

# Transaction Outcomes

## Successful Deposit

Actions performed:

1. Validate account
2. Lock account row
3. Update balance
4. Insert SUCCESS transaction
5. Commit

---

## Failed Deposit

Possible reasons include:

- Invalid account
- Blocked account
- Zero deposit amount
- Negative deposit amount
- Missing source account for non-cash transactions
- Invalid transaction channel (CHECK constraint violation)

Each failure is recorded in `TXN_LOG` with:

- Status = `FAILED`
- Appropriate error message

---

# Design Highlights

The package demonstrates several Oracle PL/SQL best practices:

- Encapsulation using packages
- Reusable business logic
- Custom exception handling
- Oracle exception mapping using `PRAGMA EXCEPTION_INIT`
- Explicit row-level locking with `FOR UPDATE`
- Transaction control using `COMMIT` and `ROLLBACK`
- Comprehensive audit logging
- Separation of validation logic from processing logic

---
# Procedure Documentation - `withdraw_money`

## Overview

The `withdraw_money` procedure is responsible for processing withdrawals from a customer account. It validates business rules, updates the account balance, records the transaction in the audit log, and ensures transactional consistency using row-level locking.

---

# Purpose

The procedure performs the following tasks:

- Validates the source account.
- Verifies the account is active.
- Checks for sufficient account balance.
- Ensures the withdrawal amount is valid.
- Validates destination account requirements for non-cash withdrawals.
- Updates the account balance.
- Records both successful and failed transactions in `TXN_LOG`.

---

# Syntax

```plsql
PROCEDURE withdraw_money(
    p_from_account_id IN ACCOUNT.account_id%TYPE,
    p_to_account_id   IN VARCHAR2 DEFAULT NULL,
    p_txn_channel     IN TXN_LOG.txn_channel%TYPE,
    p_amount          IN NUMBER
);
```

---

# Input Parameters

| Parameter | Description |
|-----------|-------------|
| `p_from_account_id` | Source account from which money is withdrawn |
| `p_to_account_id` | Destination account (optional for cash withdrawals) |
| `p_txn_channel` | Withdrawal channel |
| `p_amount` | Amount to withdraw |

---

# Supported Withdrawal Channels

The procedure currently supports:

- CASH
- ATM WITHDRAWAL
- UPI
- NEFT
- IMPS
- FUND TRANSFER

---

# Business Rules

## 1. Source account must exist

The procedure first validates the source account using the reusable `get_account_balance()` function.

---

## 2. Source account must be ACTIVE

Withdrawals are permitted only from active accounts.

Blocked accounts immediately result in a failed transaction.

---

## 3. Account must have available balance

Withdrawals are not permitted when:

- Balance is zero
- Balance is negative

---

## 4. Withdrawal amount must be greater than zero

Zero or negative withdrawal amounts are rejected.

---

## 5. Withdrawal amount cannot exceed available balance

The requested withdrawal amount must not be greater than the current account balance.

Example:

| Balance | Withdrawal | Result |
|----------|-----------:|--------|
| 10,000 | 4,000 | ✔ Success |
| 10,000 | 10,000 | ✔ Success |
| 10,000 | 12,000 | ✘ Rejected |

---

## 6. Cash withdrawals

For **CASH** withdrawals, the destination account is optional.

Example:

```
Channel : CASH

To Account : NULL

Allowed ✔
```

---

## 7. Non-cash withdrawals

For electronic withdrawals or fund transfers, the destination account is mandatory.

Example:

```
Channel : NEFT

To Account : NULL

Rejected ✘
```

---

# Processing Flow

```
Start
   │
   ▼
Validate source account
   │
   ▼
Check account status
   │
   ▼
Check available balance
   │
   ▼
Validate withdrawal amount
   │
   ▼
Validate destination account
(for non-cash transactions)
   │
   ▼
Lock source account
(FOR UPDATE)
   │
   ▼
Deduct withdrawal amount
   │
   ▼
Insert SUCCESS transaction log
   │
   ▼
Commit
```

---

# Transaction Management

Before updating the account balance, the procedure locks the account row using:

```sql
SELECT ...
FOR UPDATE;
```

This ensures:

- Only one transaction updates the account at a time.
- Concurrent withdrawals cannot produce inconsistent balances.
- Data integrity is maintained.

---

# Transaction Logging

Every execution is recorded in the `TXN_LOG` table.

## Successful Transaction

The following information is stored:

- Transaction ID
- Source Account
- Destination Account
- Transaction Type = `WITHDRAW`
- Transaction Channel
- Updated Account Balance
- Status = `SUCCESS`

---

## Failed Transaction

Whenever validation fails, a transaction record is still inserted containing:

- Status = `FAILED`
- Error message
- Requested withdrawal amount

This provides a complete audit trail for both successful and unsuccessful withdrawal attempts.

---

# Exception Handling

## Custom Exceptions

| Exception | Description |
|-----------|-------------|
| `inactive_account` | Source account is blocked or inactive |
| `zero_account_balance` | Account balance is zero or below |
| `zero_withdrawal_amount` | Withdrawal amount is zero or negative |
| `withdrawal_amt_exceeding_balance` | Requested amount exceeds available balance |
| `empty_to_account_id` | Destination account missing for non-cash withdrawals |

---

## Oracle Exception

| Exception | Description |
|-----------|-------------|
| `e_check_constraint_violation` | Raised when a CHECK constraint is violated (`ORA-02290`) |

The procedure maps the Oracle error using:

```plsql
PRAGMA EXCEPTION_INIT(
    e_check_constraint_violation,
    -2290
);
```

---

# Transaction Outcomes

## Successful Withdrawal

The procedure performs the following steps:

1. Validate source account.
2. Verify account status.
3. Validate available balance.
4. Validate withdrawal amount.
5. Lock the account row.
6. Deduct the withdrawal amount.
7. Insert a successful transaction record.
8. Commit the transaction.

---

## Failed Withdrawal

The transaction is rejected under the following conditions:

- Source account does not exist.
- Source account is blocked.
- Account balance is zero or negative.
- Withdrawal amount is zero or negative.
- Withdrawal amount exceeds available balance.
- Destination account is missing for non-cash withdrawals.
- Invalid transaction channel (CHECK constraint violation).

Each failure is logged in the transaction audit table with the corresponding error message.

---

# Design Highlights

The procedure incorporates several Oracle PL/SQL best practices:

- Encapsulation within a package
- Reuse of `get_account_balance()` for account validation
- Custom business exceptions
- Oracle exception mapping using `PRAGMA EXCEPTION_INIT`
- Explicit row-level locking using `FOR UPDATE`
- Transaction control using `COMMIT` and `ROLLBACK`
- Comprehensive audit logging for both success and failure
- Clear separation between validation logic and update logic

---

# Current Status

| Feature | Status |
|---------|--------|
| Account Validation | ✅ Implemented |
| Balance Validation | ✅ Implemented |
| Insufficient Balance Check | ✅ Implemented |
| Cash Withdrawal Support | ✅ Implemented |
| Electronic Withdrawal Support | ✅ Implemented |
| Audit Logging | ✅ Implemented |
| Row-Level Locking | ✅ Implemented |
| Exception Handling | ✅ Implemented |

---


# Current Package Contents

| Component | Status |
|-----------|--------|
| Account Balance Function | ✅ Implemented |
| Deposit Procedure | ✅ Implemented |
| Withdraw Procedure | ✅ Implemented |
| Fund Transfer Procedure | ⏳ Planned |

---

## Version

**Procedure:** `withdraw_money`

**Package:** `PKG_BANKING_SYSTEM`

**Version:** 1.1

This implementation provides a robust withdrawal process with comprehensive validations, transaction auditing, and concurrency control, serving as a foundation for future fund transfer and advanced banking operations.
