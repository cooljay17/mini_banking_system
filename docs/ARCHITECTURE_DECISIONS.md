# Design Decisions

This document captures important design decisions made during the development of the **Core Banking Mini Project**. These decisions improve the clarity, maintainability, and scalability of the database design.

---

# Transaction Log (`TXN_LOG`) Redesign

## Background

Initially, the `txn_type` column stored values such as:

- UPI
- NEFT
- IMPS
- CASH
- ATM WITHDRAWAL
- INTEREST CREDIT

This mixed **business operations** with **transaction channels**, making it difficult to determine the actual banking operation being performed.

---

## Problem

Consider the following transaction records:

| txn_type |
|----------|
| UPI |
| CASH |
| NEFT |

From these values alone, it is impossible to determine whether the transaction represents:

- A deposit
- A withdrawal
- A fund transfer

The column represented the **channel** rather than the **business operation**, which reduced reporting accuracy and complicated business logic.

---

## Solution

The transaction information was separated into two independent columns:

### `txn_type`

Represents **what banking operation occurred**.

Supported values:

- `DEPOSIT`
- `WITHDRAW`
- `TRANSFER`

This column identifies the business process responsible for creating the transaction record.

---

### `txn_channel`

Represents **how the money moved**.

Supported values include:

- `CASH`
- `UPI`
- `NEFT`
- `IMPS`
- `ATM WITHDRAWAL`
- `FUND TRANSFER`
- `INTEREST CREDIT`

This column records the payment method or channel through which the money was deposited, withdrawn, or transferred.

---

# Benefits of the Redesign

Separating transaction type from transaction channel provides several advantages:

- Clear distinction between business operations and payment channels.
- Simpler and more maintainable PL/SQL business logic.
- Easier reporting and analytics.
- Better support for future transaction channels without modifying business logic.
- Improved readability of transaction history.

---

# Example

| Transaction | `txn_type` | `txn_channel` |
|-------------|------------|---------------|
| Cash deposit | DEPOSIT | CASH |
| UPI deposit | DEPOSIT | UPI |
| ATM cash withdrawal | WITHDRAW | ATM WITHDRAWAL |
| NEFT transfer | TRANSFER | NEFT |
| IMPS transfer | TRANSFER | IMPS |
| Interest credited by bank | DEPOSIT | INTEREST CREDIT |

---

# Design Principle

The redesign follows the principle of **separation of concerns**:

- **`txn_type`** answers **"What banking operation occurred?"**
- **`txn_channel`** answers **"How did the money move?"**

Keeping these concepts separate results in a cleaner schema, more flexible reporting, and easier future enhancements.

# Why remove the `TO_ACCOUNT` foreign key?

## Background

Initially, the `TXN_LOG` table maintained foreign key relationships for both:

- `FROM_ACCT_ID`
- `TO_ACCT_ID`

While this works for account-to-account transfers, it does not support every banking transaction.

---

## Problem

Several banking operations do not always involve a destination account.

Examples include:

| Transaction | To Account Required? |
|-------------|----------------------|
| Cash Withdrawal | ❌ No |
| ATM Withdrawal | ❌ No |
| Cash Deposit | ❌ No |
| Interest Credit | ❌ No |
| Account-to-Account Transfer | ✅ Yes |
| NEFT Transfer | ✅ Yes |
| IMPS Transfer | ✅ Yes |
| UPI Transfer | ✅ Yes |

With a foreign key constraint in place, transactions without a destination account would violate referential integrity.

---


The foreign key constraint on `TO_ACCT_ID` was removed.

Instead, the application enforces business rules in the PL/SQL procedures:

- Cash withdrawals allow a `NULL` destination account.
- Electronic transfers require a valid destination account.
- Deposits and interest credits are validated according to the transaction channel.

---

## Benefits

- Supports multiple banking transaction types.
- Business rules remain in the application layer rather than the database schema.
- Easier to extend for future transaction types.
- Preserves transaction history without unnecessary constraint violations.

---

# Why use custom exceptions?

## Background

Oracle provides predefined exceptions such as:

- `NO_DATA_FOUND`
- `TOO_MANY_ROWS`
- `ZERO_DIVIDE`

However, banking applications also require handling business-specific validation failures.

---

## Design Decision

Custom exceptions are defined for business rules that are not covered by Oracle's built-in exceptions.

Examples include:

- `inactive_account`
- `zero_withdrawal_amount`
- `zero_deposit_amount`
- `withdrawal_amt_exceeding_balance`
- `empty_from_account_id`
- `empty_to_account_id`

---

## Why?

Custom exceptions make the code:

- Easier to understand.
- Easier to maintain.
- More expressive.
- Better aligned with business requirements.

For example:

Instead of:

```plsql
IF balance <= 0 THEN
    ...
END IF;
```

the procedure can clearly indicate the business failure:

```plsql
RAISE zero_account_balance;
```

This makes both the code and the exception handling more readable.

---

# Why log failed transactions?

## Background

Many applications only record successful transactions.

In banking systems, failed transactions are equally important.

---

## Design Decision

Every attempted transaction is recorded in `TXN_LOG`, regardless of whether it succeeds or fails.

Failed transactions include:

- Status (`FAILED`)
- Error message
- Attempted amount
- Source account
- Destination account (if applicable)
- Transaction type
- Transaction channel
- Timestamp

---

## Benefits

### Complete Audit Trail

Every transaction attempt is traceable, including unsuccessful ones.

---

### Easier Troubleshooting

Developers and support teams can quickly determine why a transaction failed without reproducing the issue.

---

### Customer Support

If a customer reports that a withdrawal or transfer failed, the failed transaction record provides immediate visibility into the reason.

---

### Regulatory Compliance

Financial systems are often required to maintain comprehensive audit logs, including failed transaction attempts.

---

### Analytics

Failed transaction data can be analyzed to identify:

- Frequent validation errors
- Invalid transaction channels
- User input mistakes
- Potential fraud patterns
- System issues

---

## Example

| Status | Error Message |
|--------|---------------|
| FAILED | Withdrawal amount exceeds available balance |
| FAILED | Account is blocked |
| FAILED | Invalid transaction channel |
| FAILED | Source account is required for NEFT |

Without these records, valuable operational and auditing information would be lost.

---

## Summary

These design decisions make the Core Banking Mini Project more representative of a real-world banking application by balancing data integrity, business flexibility, maintainability, and auditability.
