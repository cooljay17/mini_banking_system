CREATE OR REPLACE PACKAGE BTMS.pkg_banking_system AS    

 FUNCTION get_account_balance (
    p_account_id IN account.account_id%TYPE
) RETURN NUMBER;

END pkg_banking_system;


CREATE OR REPLACE PACKAGE BODY BTMS.pkg_banking_system AS

FUNCTION get_account_balance (
    p_account_id IN account.account_id%TYPE
) RETURN NUMBER IS
    v_balance        account.balance%TYPE;
    v_status         account.status%TYPE; -- Storing status as a string (VARCHAR2)
    inactive_account EXCEPTION;
BEGIN
    -- 1. Fetch BOTH balance and status in a single query
    SELECT balance, status
    INTO v_balance, v_status
    FROM account
    WHERE account_id = p_account_id;

    -- 2. Evaluate the status using standard PL/SQL logic
    IF v_status = 'ACTIVE' THEN
        RETURN v_balance;
    ELSE
        RAISE inactive_account;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Account ID ' || p_account_id || ' does not exist.');
        RETURN NULL;
        
    WHEN inactive_account THEN
        DBMS_OUTPUT.PUT_LINE('Error: Account ID ' || p_account_id || ' is blocked/inactive.');
        RETURN NULL;
        
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);
        RETURN NULL;
END get_account_balance;

END pkg_banking_system;
