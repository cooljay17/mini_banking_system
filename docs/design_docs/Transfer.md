# Transfer Design

## Overview

The `internal_money_transfer` procedure is designed to transfer funds between two customer accounts within the bank. The procedure performs comprehensive business validations before updating account balances and recording the transaction.

The transfer operation is **atomic**, meaning both the debit and credit operations succeed together or fail together. If any validation or database operation fails, the entire transaction is rolled back to maintain data consistency.

---

# Procedure Name

```plsql
internal_money_transfer
```

---

# Input Parameters

| Parameter | Description |
|-----------|-------------|
| `p_from_account_id` | Source account from which money will be debited |
| `p_to_account_id` | Destination account that will receive the funds |
| `p_amount` | Amount to transfer |
| `p_txn_channel` | Transfer channel (NEFT, IMPS, UPI, FUND TRANSFER, etc.) |
| `p_remarks` | Optional remarks or description for the transaction |

---

# Business Flow

```
Start
   │
   ▼
Validate Transfer Amount
(amount > 0)
   │
   ▼
Validate Source Account
• Exists
• Active
• Balance > 0
• Balance >= Transfer Amount
   │
   ▼
Validate Destination Account
• Exists
• Active
   │
   ▼
Check Source and Destination Accounts
• Must not be the same
   │
   ▼
Lock Both Account Rows
(FOR UPDATE)
   │
   ▼
Debit Source Account
   │
   ▼
Credit Destination Account
   │
   ▼
Insert Transaction Log
   │
   ▼
Commit
```

---

# Validation Rules

## 1. Validate Transfer Amount

The transfer amount must be greater than zero.

**Validation**

- Amount > 0

If the validation fails, the transaction is rejected.

---

## 2. Validate Source Account

The source account must satisfy all of the following conditions:

- Account exists.
- Account status is **ACTIVE**.
- Account balance is greater than zero.
- Account balance is greater than or equal to the transfer amount.

---

## 3. Validate Destination Account

The destination account must:

- Exist.
- Be in **ACTIVE** status.

---

## 4. Validate Same Account

The source and destination accounts cannot be identical.

Example:

```
From Account : 100001

To Account   : 100001

Result       : Rejected
```

---

# Account Update Flow

After all validations succeed:

1. Lock the source account.
2. Lock the destination account.
3. Debit the source account.
4. Credit the destination account.
5. Record the transaction.
6. Commit the transaction.

If any step fails, the transaction is rolled back.

---

# Transaction Logging

A successful transfer inserts a record into `TXN_LOG` containing:

- Transaction ID
- From Account
- To Account
- Transaction Type (`TRANSFER`)
- Transaction Channel
- Transfer Amount
- Status (`SUCCESS`)
- Remarks
- Timestamp

If the transfer fails, a transaction log is still inserted with:

- Status = `FAILED`
- Error Message
- Attempted Transfer Amount
- Transaction Details

---

# Transaction Management

The procedure performs both the debit and credit operations within a single database transaction.

To prevent concurrent updates, both account rows should be locked using:

```sql
SELECT ...
FOR UPDATE;
```

This ensures:

- No simultaneous modification of the same accounts.
- Consistent account balances.
- Atomic execution of the transfer.

---

# Planned Custom Exceptions

| Exception | Purpose |
|-----------|---------|
| `inactive_source_account` | Source account is blocked or inactive |
| `inactive_destination_account` | Destination account is blocked or inactive |
| `invalid_transfer_amount` | Transfer amount is zero or negative |
| `insufficient_balance` | Transfer amount exceeds available balance |
| `same_account_transfer` | Source and destination accounts are the same |
| `invalid_transaction_channel` | Unsupported transaction channel |
| `e_check_constraint_violation` | Oracle CHECK constraint violation (`ORA-02290`) |

---

# Design Principles

The `internal_money_transfer` procedure follows these design principles:

- **Atomic Transactions** – Debit and credit occur together or not at all.
- **Comprehensive Validation** – All business rules are validated before modifying data.
- **Data Integrity** – Row-level locking prevents concurrent update issues.
- **Auditability** – Both successful and failed transfer attempts are recorded.
- **Reusability** – Existing validation functions (such as `get_account_balance`) can be reused to minimize duplicate logic.

---

# Future Enhancements

The following enhancements are planned for future versions:

- Daily transfer limits.
- Maximum transaction amount validation.
- External Account Transactions

---

## Version 

**Procedure:** `internal_money_transfer`

**Status:** Design Complete – Implementation Pending

**Version:** 1.0
