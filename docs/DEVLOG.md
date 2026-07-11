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
