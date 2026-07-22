CREATE OR REPLACE PACKAGE BTMS.pkg_banking_system AS    

 FUNCTION get_account_balance (
    p_account_id IN account.account_id%TYPE
) RETURN NUMBER;

PROCEDURE deposit_money(
    p_from_account_id IN VARCHAR2 DEFAULT NULL,
	p_to_account_id IN ACCOUNT.account_id%TYPE,
	p_txn_type IN TXN_LOG.txn_type%TYPE,
    p_amount     IN NUMBER);

END pkg_banking_system;


CREATE OR REPLACE PACKAGE BODY BTMS.pkg_banking_system AS

--------------------------------------------------------------------------------
-- FUNCTION: get_account_balance
--------------------------------------------------------------------------------
FUNCTION get_account_balance (
    p_account_id IN account.account_id%TYPE
) RETURN NUMBER IS
    v_balance        account.balance%TYPE;
    v_status         account.status%TYPE;
    inactive_account EXCEPTION;
BEGIN
    SELECT balance, status
    INTO v_balance, v_status
    FROM account
    WHERE account_id = p_account_id;

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


--------------------------------------------------------------------------------
-- PROCEDURE: deposit_money
--------------------------------------------------------------------------------
PROCEDURE deposit_money(
    p_from_account_id IN VARCHAR2 DEFAULT NULL,
    p_to_account_id   IN account.account_id%TYPE,
    p_txn_type        IN txn_log.txn_type%TYPE,
    p_amount          IN NUMBER
) IS
    
    v_balance           NUMBER := 0;
    zero_deposit_amount EXCEPTION;
    inactive_account    EXCEPTION;
BEGIN
   
    v_balance := get_account_balance(p_to_account_id);

    IF v_balance IS NOT NULL AND p_amount > 0 THEN
        UPDATE account
        SET balance = balance + p_amount,
        Last_modified_at=sysdate
        WHERE account_id = p_to_account_id;
        
        INSERT INTO txn_log (
            txn_id,        
            from_acct_id,
            to_acct_id,
            txn_type,
            status,
            AMOUNT,
            created_at
        ) VALUES (
            seq_txn_id.NEXTVAL,
            p_from_account_id,
            p_to_account_id,
            p_txn_type,
            'SUCCESS',
            v_balance+p_amount,
            sysdate
        );        
        COMMIT;

    ELSIF p_amount <= 0 THEN
        INSERT INTO txn_log (
            txn_id,        
            from_acct_id,
            to_acct_id,
            txn_type,
            status,
            error_msg,
            AMOUNT,
            created_at
        ) VALUES (
            seq_txn_id.NEXTVAL,
            p_from_account_id,
            p_to_account_id,
            p_txn_type,
            'FAILED',
            'Zero/Negative Deposit Amount',
            p_amount,
            sysdate
        );    
        COMMIT;
        RAISE zero_deposit_amount;
    
    ELSE
        INSERT INTO txn_log (
            txn_id,        
            from_acct_id,
            to_acct_id,
            txn_type,
            status,
            error_msg,
            AMOUNT,
            created_at
        ) VALUES (
            seq_txn_id.NEXTVAL,
            p_from_account_id,
            p_to_account_id,
            p_txn_type,
            'FAILED',
            'Blocked/inactive account',
            0,
            sysdate
        );    
        COMMIT;
        RAISE inactive_account;
        
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Account ID ' || p_to_account_id || ' does not exist.');
        
    WHEN inactive_account THEN
        DBMS_OUTPUT.PUT_LINE('Error: Account ID ' || p_to_account_id || ' is blocked/inactive.');
        
    WHEN zero_deposit_amount THEN
        DBMS_OUTPUT.PUT_LINE('Error: Deposit amount must be greater than zero.');

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);

END deposit_money;

END pkg_banking_system;
