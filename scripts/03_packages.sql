CREATE OR REPLACE PACKAGE BTMS.pkg_banking_system AS    

 FUNCTION get_account_balance (
    p_account_id IN account.account_id%TYPE
) RETURN NUMBER;

PROCEDURE deposit_money(
    p_from_account_id IN ACCOUNT.account_id%TYPE,
	p_to_account_id IN ACCOUNT.account_id%TYPE,
    p_amount     IN NUMBER
);

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

PROCEDURE deposit_money(
    p_from_account_id IN ACCOUNT.account_id%TYPE,
	p_to_account_id IN ACCOUNT.account_id%TYPE,
	txn_type IN TXN_LOG.txn_type%TYPE,
    p_amount     IN NUMBER)
	
	BEGIN
	v_balance NUMBER:=0;
	zero_Deposit_Amount Exception;
	select get_account_balance(p_to_account_id)
	into v_balance
	from dual;
	
		
	IF v_balance is not null and p_amount>0  THEN
		UPDATE account
		SET balance = balance + p_amount
		WHERE account_id = p_to_account_id;
		
		INSERT INTO TXN_LOG
		(txn_id,		
		from_acct_id,
		to_acct_id,
		txn_type,
		status) 
		VALUES
		(
		seq_txn_id.NEXT_VAL,
		p_from_account_id,
		p_to_account_id,
		txn_type,
		'SUCCESS');		
		commit;
	  IF 	
    ELSIF p_amount<=0 THEN
		INSERT INTO TXN_LOG
		(txn_id,		
		from_acct_id,
		to_acct_id,
		txn_type,
		status) 
		VALUES
		(
		seq_txn_id.NEXT_VAL,
		p_from_account_id,
		p_to_account_id,
		txn_type,
		'FAILED',
		'Zero Deposit Amount');	
		commit;
		Raise zero_Deposit_Amount;
	
	ELSE
		INSERT INTO TXN_LOG
		(txn_id,		
		from_acct_id,
		to_acct_id,
		txn_type,
		status) 
		VALUES
		(
		seq_txn_id.NEXT_VAL,
		p_from_account_id,
		p_to_account_id,
		txn_type,
		'FAILED',
		'blocked/inactive account');	
		commit;
        RAISE inactive_account;
		
    END IF;
	
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			DBMS_OUTPUT.PUT_LINE('Error: Account ID ' || p_account_id || ' does not exist.');
			RETURN NULL;
        
		WHEN inactive_account THEN
			DBMS_OUTPUT.PUT_LINE('Error: Account ID ' || p_account_id || ' is blocked/inactive.');
        
		WHEN zero_Deposit_Amount THEN
			DBMS_OUTPUT.PUT_LINE('Error: Deposit amount must be greater than zero.');
        
	
	END deposit_money;

END pkg_banking_system;
