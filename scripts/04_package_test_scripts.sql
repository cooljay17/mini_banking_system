SET SERVEROUTPUT ON;

BEGIN
    pkg_banking_system.deposit_money(
        p_from_account_id => NULL,
        p_to_account_id   => 501,
        p_txn_type        => 'CASH', 
        p_amount          => 1000
    );

    DBMS_OUTPUT.PUT_LINE('Deposit Successful');
END;
/

BEGIN
    pkg_banking_system.deposit_money(
        p_from_account_id => 95000,
        p_to_account_id   => 705,
        p_txn_type      => 'DEPOSIT',
        p_amount          => 10000
    );
END;


BEGIN
    pkg_banking_system.deposit_money(
        p_from_account_id => '77789890790',
        p_to_account_id   => 675,
        p_txn_type      => 'NEFT',
        p_amount          => -900
    );
END;
/