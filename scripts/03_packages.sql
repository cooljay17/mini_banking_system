CREATE OR REPLACE PACKAGE BODY BTMS.pkg_banking_system AS

  ------------------------------------------------------------------------------
  -- FUNCTION: get_account_balance
  ------------------------------------------------------------------------------
  FUNCTION get_account_balance (
    p_account_id IN account.account_id%TYPE
  ) RETURN NUMBER IS
    v_balance         account.balance%TYPE;
    v_status          account.status%TYPE;
    inactive_account  EXCEPTION;
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

  ------------------------------------------------------------------------------
  -- PROCEDURE: deposit_money
  ------------------------------------------------------------------------------
  PROCEDURE deposit_money (
    p_from_account_id IN VARCHAR2,
	p_to_account_id   IN account.account_id%TYPE,
    p_txn_channel     IN txn_log.txn_channel%TYPE,
    p_amount          IN NUMBER
  ) IS
    v_chk_balance                 NUMBER := 0;
    v_balance                     NUMBER := 0;
    v_txn_type CONSTANT           txn_log.txn_type%TYPE := 'DEPOSIT';
  	v_is_from_acct_null			  BOOLEAN      := TRUE;
 

    zero_deposit_amount           EXCEPTION;
    inactive_account              EXCEPTION;
    empty_from_account_id         EXCEPTION;
    e_check_constraint_violation  EXCEPTION;

    PRAGMA EXCEPTION_INIT(e_check_constraint_violation, -2290);
    
  BEGIN	  
	
    IF p_txn_channel <> 'CASH' AND  p_from_account_id IS  NULL THEN
           	v_is_from_acct_null:=FALSE;            
    END IF;   
    
    v_chk_balance := get_account_balance(p_to_account_id);

    IF v_chk_balance IS  NULL  THEN
       INSERT INTO txn_log (
        txn_id,
        from_acct_id,
        to_acct_id,
        txn_type,
        txn_channel,
        status,
        error_msg,
        amount,
        created_at
      ) VALUES (
        seq_txn_id.NEXTVAL,
        p_from_account_id,
        p_to_account_id,
        v_txn_type,
        p_txn_channel,
        'FAILED',
        'Blocked/inactive account',
        0,
        SYSDATE
      );

      COMMIT;
      RAISE inactive_account;
      

    ELSIF p_amount <= 0 THEN
	  INSERT INTO txn_log (
        txn_id,
        from_acct_id,
        to_acct_id,
        txn_type,
        txn_channel,
        status,
        error_msg,
        amount,
        created_at
      ) VALUES (
        seq_txn_id.NEXTVAL,
        p_from_account_id,
        p_to_account_id,
        v_txn_type,
        p_txn_channel,
        'FAILED',
        'Zero/Negative Deposit Amount',
        p_amount,
        SYSDATE
      );

      COMMIT;
      RAISE zero_deposit_amount;
      
    ELSIF v_is_from_acct_null=FALSE THEN
	  INSERT INTO txn_log (
        txn_id,
        from_acct_id,
        to_acct_id,
        txn_type,
        txn_channel,
        status,
        error_msg,
        amount,
        created_at
      ) VALUES (
        seq_txn_id.NEXTVAL,
        p_from_account_id,
        p_to_account_id,
        v_txn_type,
        p_txn_channel,
        'FAILED',
        'From account is null and transaction channel is not cash',
        p_amount,
        SYSDATE
      );

      COMMIT;
      RAISE empty_from_account_id;  
    
    ELSE
    	-- Transaction Phase 1: Lock the source row and update
      BEGIN
        SELECT balance
          INTO v_balance
          FROM account
         WHERE account_id = p_to_account_id 
           FOR UPDATE;  -- Explicit row lock

        UPDATE account
           SET balance          = v_balance + p_amount,
               last_modified_at = SYSDATE
         WHERE account_id = p_to_account_id;
        DBMS_OUTPUT.PUT_LINE('Deposit::Account ID ' || p_to_account_id || ' updated with new balance successfully');

        INSERT INTO txn_log (
          txn_id,
          from_acct_id,
          to_acct_id,
          txn_type,
          txn_channel,
          status,
          amount,
          created_at
        ) VALUES (
          seq_txn_id.NEXTVAL,
          p_from_account_id,
          p_to_account_id,
          v_txn_type,
          p_txn_channel,
          'SUCCESS',
          v_chk_balance + p_amount,
          SYSDATE
        );
		DBMS_OUTPUT.PUT_LINE('Deposit::Transaction log Record inserted for Account ID ' || p_to_account_id || ' updated with new balance successfully');
        COMMIT;

      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;  -- Undoes transaction if lock/update fails
          RAISE;
      END;
	 
  END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('Error: Account ID ' || p_to_account_id || ' does not exist.');

    WHEN inactive_account THEN
      DBMS_OUTPUT.PUT_LINE('Error: Account ID ' || p_to_account_id || ' is blocked/inactive.');

    WHEN zero_deposit_amount THEN
      DBMS_OUTPUT.PUT_LINE('Error: Deposit amount must be greater than zero.');
    
    WHEN empty_from_account_id THEN
      DBMS_OUTPUT.PUT_LINE('Error: From Account ID is NULL for the Transaction channel which is not CASH');

    WHEN e_check_constraint_violation THEN
      DBMS_OUTPUT.PUT_LINE('Data integrity failure: Value violates table check rules.');
      DBMS_OUTPUT.PUT_LINE('Technical error details: ' || SQLERRM);

    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);

  END deposit_money;
  
  ------------------------------------------------------------------------------
  -- PROCEDURE: withdraw_money
  ------------------------------------------------------------------------------
  PROCEDURE withdraw_money (
	p_from_account_id IN account.account_id%TYPE,
	p_to_account_id   IN VARCHAR2,
	p_txn_channel     IN txn_log.txn_channel%TYPE,
	p_amount          IN NUMBER
	) 
	
	IS
    v_chk_balance                 NUMBER := 0;
    v_balance                     NUMBER := 0;
    v_txn_type  CONSTANT          txn_log.txn_type%TYPE := 'WITHDRAW';
  	v_is_to_acct_null			  BOOLEAN      := TRUE;
	
 

    zero_account_balance           EXCEPTION;
	zero_withdrawal_amount           EXCEPTION;
    withdrawal_amt_exceeding_balance EXCEPTION;
    inactive_account              EXCEPTION;
    empty_to_account_id             EXCEPTION;
    e_check_constraint_violation  EXCEPTION;

    PRAGMA EXCEPTION_INIT(e_check_constraint_violation, -2290);
    
  BEGIN	  
	
    IF p_txn_channel <> 'CASH' AND  p_to_account_id IS  NULL THEN
           	v_is_to_acct_null:=FALSE;            
    END IF;
   
    
    v_chk_balance := get_account_balance(p_from_account_id);

    IF v_chk_balance IS NULL THEN
    	INSERT INTO txn_log (
        txn_id,
        from_acct_id,
        to_acct_id,
        txn_type,
        txn_channel,
        status,
        error_msg,
        amount,
        created_at
      ) VALUES (
        seq_txn_id.NEXTVAL,
        p_from_account_id,
        p_to_account_id,
        v_txn_type,
        p_txn_channel,
        'FAILED',
        'Blocked/inactive account',
        0,
        SYSDATE
      );

      COMMIT;
      RAISE inactive_account;
      
    ELSIF v_chk_balance <= 0 THEN
	  INSERT INTO txn_log (
        txn_id,
        from_acct_id,
        to_acct_id,
        txn_type,
        txn_channel,
        status,
        error_msg,
        amount,
        created_at
      ) VALUES (
        seq_txn_id.NEXTVAL,
        p_from_account_id,
        p_to_account_id,
        v_txn_type,
        p_txn_channel,
        'FAILED',
        'Zero/Negative Account Balance',
        p_amount,
        SYSDATE
      );

      COMMIT;
      RAISE zero_account_balance;    
	  
	ELSIF p_amount <= 0 THEN
	  INSERT INTO txn_log (
        txn_id,
        from_acct_id,
        to_acct_id,
        txn_type,
        txn_channel,
        status,
        error_msg,
        amount,
        created_at
      ) VALUES (
        seq_txn_id.NEXTVAL,
        p_from_account_id,
        p_to_account_id,
        v_txn_type,
        p_txn_channel,
        'FAILED',
        'Zero/Negative Withdrawal Amount',
        p_amount,
        SYSDATE
      );

      COMMIT;
      RAISE zero_withdrawal_amount;
    ELSIF p_amount > v_chk_balance THEN
	  INSERT INTO txn_log (
        txn_id,
        from_acct_id,
        to_acct_id,
        txn_type,
        txn_channel,
        status,
        error_msg,
        amount,
        created_at
      ) VALUES (
        seq_txn_id.NEXTVAL,
        p_from_account_id,
        p_to_account_id,
        v_txn_type,
        p_txn_channel,
        'FAILED',
        'Withdrawal Amount is exceeding Account Balance',
        p_amount,
        SYSDATE
      );

      COMMIT;
      RAISE withdrawal_amt_exceeding_balance;
      
    ELSIF v_is_to_acct_null=FALSE THEN
	  INSERT INTO txn_log (
        txn_id,
        from_acct_id,
        to_acct_id,
        txn_type,
        txn_channel,
        status,
        error_msg,
        amount,
        created_at
      ) VALUES (
        seq_txn_id.NEXTVAL,
        p_from_account_id,
        p_to_account_id,
        v_txn_type,
        p_txn_channel,
        'FAILED',
        'To account is null and transaction channel is not cash',
        p_amount,
        SYSDATE
      );

      COMMIT;
      RAISE empty_to_account_id;  
    
    ELSE 
      -- Transaction Phase 1: Lock the source row and update
      BEGIN
        SELECT balance
          INTO v_balance
          FROM account
         WHERE account_id = p_from_account_id 
           FOR UPDATE;  -- Explicit row lock

        UPDATE account
           SET balance          = v_balance - p_amount,
               last_modified_at = SYSDATE
         WHERE account_id = p_from_account_id;
        DBMS_OUTPUT.PUT_LINE('Withdraw::Account ID ' || p_from_account_id || ' updated with new balance successfully');

        INSERT INTO txn_log (
          txn_id,
          from_acct_id,
          to_acct_id,
          txn_type,
          txn_channel,
          status,
          amount,
          created_at
        ) VALUES (
          seq_txn_id.NEXTVAL,
          p_from_account_id,
          p_to_account_id,
          v_txn_type,
          p_txn_channel,
          'SUCCESS',
          v_chk_balance - p_amount,
          SYSDATE
        );
		DBMS_OUTPUT.PUT_LINE('Withdraw::Transaction log Record inserted for Account ID ' || p_from_account_id || ' updated with new balance successfully');
        COMMIT;

      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;  -- Undoes transaction if lock/update fails
          RAISE;
      END;

  END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('Error: Account ID ' || p_from_account_id || ' does not exist.');

    WHEN inactive_account THEN
      DBMS_OUTPUT.PUT_LINE('Error: Account ID ' || p_from_account_id || ' is blocked/inactive.');

    WHEN zero_account_balance THEN
      DBMS_OUTPUT.PUT_LINE('Error: Account Balance is zero or below');
	  
	WHEN zero_withdrawal_amount THEN
      DBMS_OUTPUT.PUT_LINE('Error: Withdrawal amount must be greater than zero.');
	
	WHEN withdrawal_amt_exceeding_balance THEN
      DBMS_OUTPUT.PUT_LINE('Error: Withdrawal Amount is exceeding Account Balance.');
    
    WHEN empty_to_account_id THEN
      DBMS_OUTPUT.PUT_LINE('Error: To Account ID is NULL for the Transaction channel which is not CASH');

    WHEN e_check_constraint_violation THEN
      DBMS_OUTPUT.PUT_LINE('Data integrity failure: Value violates table check rules.');
      DBMS_OUTPUT.PUT_LINE('Technical error details: ' || SQLERRM);

    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);

  END withdraw_money;

END pkg_banking_system;
