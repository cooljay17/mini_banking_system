# Banking Transaction Management System (BTMS) – Progress Journal

## Day 1

### Accomplishments

- Created the following database tables:
  - CUSTOMER
  - ACCOUNT
  - TXN_LOG
  - ACCOUNT_TYPE
- Populated the **ACCOUNT_TYPE** master table with different account types, including:
  - Savings
  - Current
  - Salary
  - Fixed Deposit

### Challenge

There was a lot of information to consider at the beginning, so I decided to focus only on the essentials and build incrementally.

### What I Learned

- Start simple and build the solution step by step.
- Designing realistic master data is just as important as creating the database schema.
- Investing time in well-structured reference tables improves the quality of the overall system.

### Next Steps

- Generate and insert sample data into the remaining tables.

---

## Day 2

### Accomplishments

While generating sample data, I identified several gaps in the initial database design.

Enhancements made:

- Created a new **BRANCH** table.
- Added an ALTER script to establish a foreign key relationship between **ACCOUNT** and **BRANCH**.
- Added **FIRST_NAME** and **SURNAME** columns to the **CUSTOMER** table.
- Configured the **CREATED_DATE** column in all tables to default to **SYSDATE**.
- Generated realistic sample CSV files and successfully loaded:
  - **1,000 Customers**
  - **200 Branches**
  - **3,000 Accounts**

### Challenge

The sample data was generated with the help of AI prompts to make it as realistic as possible. While it closely resembles real-world banking data, some relationships and distributions may not perfectly reflect actual production systems.

As the project evolves, I expect to refine, regenerate, or completely replace portions of the sample data to better support future features and testing.

### What I Learned

This exercise made me realize that database modeling is much more than writing `CREATE TABLE` statements or defining primary and foreign keys.

Effective database design requires visualizing the business domain, understanding how entities interact, and continuously refining the model as new requirements emerge.

### Next Steps

- Generate and insert sample data for the **TXN_LOG** table.
- Begin planning and implementing the PL/SQL components for the application.

## Day 3

### Accomplishments

- Successfully loaded **10,000 sample records** into the **TXN_LOG** table.
- Expanded the list of transaction types beyond the initial four to better reflect real-world banking operations.
- Created the initial **PL/SQL package skeleton**, including:
  - Package Specification (Declaration)
  - Package Body

### Challenge

While modifying the `CHECK` constraint for the transaction types using the `ALTER TABLE` command, I discovered that the existing constraint was still present.

I learned that before creating a new `CHECK` constraint, the old constraint must first be dropped using its constraint name. This was a valuable lesson in managing database schema changes.

### What I Learned

- Schema modifications require careful management of existing constraints.
- Understanding constraint names and how to modify them is an important part of database maintenance.
- Building the package structure first provides a solid foundation before implementing the business logic.

### Next Steps

- Design and implement the PL/SQL package procedures and functions.
- Begin adding core banking operations such as deposits, withdrawals, fund transfers, and balance enquiries.

## Day 4

### Accomplishments

- Successfully implemented my first PL/SQL function and included it within a package.
- Executed the package successfully and verified the function worked as expected.
- Developed a simple **Account Balance Check** function.
- Added business validation using a **user-defined exception** to raise an error when an account is inactive.

### Challenge

One issue kept me stuck for quite some time—the `/` at the end of the package script. It was causing compilation errors because of how I was executing the script.

After troubleshooting, I realized that I should **ignore/remove the `/`** in my current execution environment. Once I did that, the package compiled successfully.

It was a simple issue, but an important lesson in understanding how different SQL execution tools handle PL/SQL scripts.

### What I Learned

- PL/SQL packages provide a clean way to organize related business logic.
- User-defined exceptions make the code more readable and allow business rules to be handled explicitly.
- After a long gap, I realized my PL/SQL skills had become rusty. The concepts are familiar, but rebuilding confidence comes from writing code consistently.
- Most importantly, I reminded myself **not to overcomplicate the solution**. Building one small, working feature at a time is far more effective than trying to solve everything at once.

### Next Steps

- Add more banking operations to the package, starting with **Deposit**, **Withdrawal**, and **Fund Transfer** procedures.
- Strengthen exception handling and transaction management.
- Continue building the package incrementally while keeping the code simple, readable, and testable.

### Interview Takeaway

If an interviewer asked me about today's work, I would say:

> "As part of rebuilding my PL/SQL skills, I implemented a **Check Balance** function within a PL/SQL package. The function includes business validation using a user-defined exception to prevent inactive accounts from retrieving their balance. During development, I encountered package compilation issues related to how my SQL client executed PL/SQL scripts. After diagnosing the root cause, I corrected the issue and successfully compiled the package. This exercise reinforced not only my PL/SQL programming skills but also the importance of understanding how development tools handle script execution."
  
