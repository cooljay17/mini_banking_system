SET SERVEROUTPUT ON;
--Success criteria
BEGIN
    pkg_banking_system.deposit_money(
        p_from_account_id => NULL,
        p_to_account_id   => 501,
        p_txn_channel        => 'CASH', 
        p_amount          => 2000
    );
    
END;

--Failure-From account null other than CASH
BEGIN
    pkg_banking_system.deposit_money(
        p_from_account_id => NULL,
        p_to_account_id   => 501,
        p_txn_channel        => 'NEFT', 
        p_amount          => 2000
    );
    
END;

--Failure-Check constraint check
BEGIN
    pkg_banking_system.deposit_money(
        p_from_account_id => 95000,
        p_to_account_id   => 705,
        p_txn_channel      => 'DEPOSIT',
        p_amount          => 10000
    );
END;

--Failure-Negative deposit amount
BEGIN
    pkg_banking_system.deposit_money(
        p_from_account_id => '77789890790',
        p_to_account_id   => 675,
        p_txn_channel      => 'NEFT',
        p_amount          => -900
    );
END;
