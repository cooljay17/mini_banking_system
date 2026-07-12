CREATE OR REPLACE PACKAGE pkg_banking_system AS    
PROCEDURE open_account(p_customer_id NUMBER,
p_branch_code VARCHAR2,
p_account_type VARCHAR2, 
p_opening_balance OUT NUMBER, 
p_account_id OUT NUMBER);

END pkg_banking_system; 
/