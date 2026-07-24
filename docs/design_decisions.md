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
