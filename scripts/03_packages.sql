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
    p_from_account_id IN VARCHAR2 DEFAULT NULL,
    p_to_account_id   IN account.account_id%TYPE,
    p_txn_channel     IN txn_log.txn_channel%TYPE,
    p_amount          IN NUMBER
  ) IS
    v_chk_balance                 NUMBER := 0;
    v_balance                     NUMBER := 0;
    v_txn_type                    VARCHAR2(10) := 'DEPOSIT';

    zero_deposit_amount           EXCEPTION;
    inactive_account              EXCEPTION;
    e_check_constraint_violation  EXCEPTION;

    PRAGMA EXCEPTION_INIT(e_check_constraint_violation, -2290);
  BEGIN
    v_chk_balance := get_account_balance(p_to_account_id);

    IF v_chk_balance IS NOT NULL AND p_amount > 0 THEN
      
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

        COMMIT;

      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;  -- Undoes transaction if lock/update fails
          RAISE;
      END;

    ELSIF p_amount <= 0 THEN
	BEGIN
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
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;  
          RAISE;
	END;
    ELSE
	BEGIN
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

    WHEN e_check_constraint_violation THEN
      DBMS_OUTPUT.PUT_LINE('Data integrity failure: Value violates table check rules.');
      DBMS_OUTPUT.PUT_LINE('Technical error details: ' || SQLERRM);

    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);

  END deposit_money;

END pkg_banking_system;