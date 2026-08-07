SET SERVEROUTPUT ON;
-------------------------------------------------------
----Deposit_money----
------------------------------------------------------
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
-------------------------------------------------------
----Withdraw_money----
------------------------------------------------------
--Success criteria
BEGIN
    pkg_banking_system.withdraw_money(
        p_from_account_id => 501,
        p_to_account_id   => NULL,
        p_txn_channel        => 'CASH', 
        p_amount          => 2000
    );
    
END;

--Failure-To account null other than CASH
BEGIN
    pkg_banking_system.withdraw_money(
        p_from_account_id => 501,
        p_to_account_id   => NULL,
        p_txn_channel        => 'NEFT', 
        p_amount          => 2000
    );
    
END;

--Failure-Check constraint check
BEGIN
    pkg_banking_system.withdraw_money(
        p_from_account_id => 501,
        p_to_account_id   => 987605,
        p_txn_channel        => 'WITHDRAW', 
        p_amount          => 2000
    );
    
END;


--Failure-Higher withdrwal amount
BEGIN
    pkg_banking_system.withdraw_money(
        p_from_account_id => 501,
        p_to_account_id   => '77789890790',
        p_txn_channel      => 'NEFT',
        p_amount          => 1624000
    );
END;


--Failure-Zero/negative withdrwal amount
BEGIN
    pkg_banking_system.withdraw_money(
        p_from_account_id => 501,
        p_to_account_id   => '77789890790',
        p_txn_channel      => 'NEFT',
        p_amount          => 0
    );
END;


--Failure-Account Blocked
BEGIN
    pkg_banking_system.withdraw_money(
        p_from_account_id => 499,
        p_to_account_id   => '77789890790',
        p_txn_channel      => 'NEFT',
        p_amount          => 277500
    );
END;
-------------------------------------------------------
----internal_transfer_money----
------------------------------------------------------
--Success criteria
BEGIN
    pkg_banking_system.internal_transfer_money(
        p_from_account_id => 501,
        p_to_account_id   => 500,
        p_txn_channel        => 'CASH', 
        p_amount          => 20000
    );
    
END;


--Failure-Check constraint check
BEGIN
    pkg_banking_system.internal_transfer_money(
        p_from_account_id => 501,
        p_to_account_id   => 500,
        p_txn_channel        => 'WITHDRAW', 
        p_amount          => 2000
    );
    
END;


--Failure-Higher transfer amount
BEGIN
    pkg_banking_system.internal_transfer_money(
        p_from_account_id => 501,
        p_to_account_id   => 500,
        p_txn_channel      => 'UPI',
        p_amount          => 6450000
    );
END;


--Failure-Zero/negative Transfer amount
BEGIN
    pkg_banking_system.internal_transfer_money(
        p_from_account_id => 501,
        p_to_account_id   => 500,
        p_txn_channel      => 'NEFT',
        p_amount          => -500
    );
END;


--Failure-From Account Blocked
BEGIN
    pkg_banking_system.internal_transfer_money(
        p_from_account_id => 499,
        p_to_account_id   => 500,
        p_txn_channel      => 'NEFT',
        p_amount          => 277500
    );
END;

--Failure-To Account Blocked
BEGIN
    pkg_banking_system.internal_transfer_money(
        p_from_account_id => 500,
        p_to_account_id   => 499,
        p_txn_channel      => 'NEFT',
        p_amount          => 277500
    );
END;

--Failure-same account
BEGIN
    pkg_banking_system.internal_transfer_money(
        p_from_account_id => 501,
        p_to_account_id   => 501,
        p_txn_channel      => 'NEFT',
        p_amount          => 277500
    );
END;