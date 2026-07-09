--Account_TYPE
--SAVINGS ACCOUNT
INSERT INTO ACCOUNT_TYPE(account_TYPE_CODE,account_TYPE_DESC,created_at)
values('SBCHQ','General Savings with Cheque',sysdate);
INSERT INTO ACCOUNT_TYPE(account_TYPE_CODE,account_TYPE_DESC,created_at)
values('SBGEN','General Savings without Cheque',sysdate);
INSERT INTO ACCOUNT_TYPE(account_TYPE_CODE,account_TYPE_DESC,created_at)
values('SBBAS2','Basic Savings Bank Deposit Account (Zero Balance)',sysdate);

--CURRENT ACCOUNT
INSERT INTO ACCOUNT_TYPE(account_TYPE_CODE,account_TYPE_DESC,created_at)
values('CAGEN','General Current Account',sysdate);
INSERT INTO ACCOUNT_TYPE(account_TYPE_CODE,account_TYPE_DESC,created_at)
values('CACOL','Corporate Current Account',sysdate);
INSERT INTO ACCOUNT_TYPE(account_TYPE_CODE,account_TYPE_DESC,created_at)
values('CA0033','Institutional/Government Account',sysdate);


--SALARY ACCOUNT
INSERT INTO ACCOUNT_TYPE(account_TYPE_CODE,account_TYPE_DESC,created_at)
values('SB101','Standard Salary Account',sysdate);
INSERT INTO ACCOUNT_TYPE(account_TYPE_CODE,account_TYPE_DESC,created_at)
values('SBODS4','Corporate/Staff Salary Account',sysdate);

--FIXED DEPOSIT
INSERT INTO ACCOUNT_TYPE(account_TYPE_CODE,account_TYPE_DESC,created_at)
values('TD001','General Fixed Deposit',sysdate);
INSERT INTO ACCOUNT_TYPE(account_TYPE_CODE,account_TYPE_DESC,created_at)
values('TD003','Senior Citizen Fixed Deposit',sysdate);
INSERT INTO ACCOUNT_TYPE(account_TYPE_CODE,account_TYPE_DESC,created_at)
values('TD002','Staff Fixed Deposit',sysdate);

COMMIT;

