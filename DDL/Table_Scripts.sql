-- DROP USER BTMS;

CREATE USER BTMS
-- IDENTIFIED BY <password>
;

--CUSTOMER
CREATE TABLE CUSTOMER (
customer_id NUMBER PRIMARY KEY,
address VARCHAR2(250),
Phone NUMBER(15),
email VARCHAR2(100),
PAN VARCHAR2(10) NOT NULL,
AADHAR NUMBER(12) NOT NULL,
status VARCHAR2(10) DEFAULT 'ACTIVE' NOT NULL
    CHECK (status IN ('ACTIVE', 'BLOCKED')),
created_at DATE,
Last_modified_at DATE
);

--ACCOUNT_TYPE
CREATE TABLE ACCOUNT_TYPE (
account_TYPE_CODE VARCHAR2(20) PRIMARY KEY,
account_TYPE_DESC VARCHAR2(200),
created_at DATE,
Last_modified_at DATE
);
--ACCOUNT
CREATE TABLE ACCOUNT (
account_id NUMBER PRIMARY KEY,
BRANCH_CODE VARCHAR2(100),
customer_id NUMBER REFERENCES CUSTOMER(customer_id),
ACCOUNT_TYPE VARCHAR2(25)REFERENCES ACCOUNT_TYPE(account_TYPE_CODE),
balance NUMBER NOT NULL,
status VARCHAR2(10) DEFAULT 'ACTIVE' NOT NULL
    CHECK (status IN ('ACTIVE', 'BLOCKED')),
created_at DATE,
Last_modified_at DATE
);

--transaction audit
CREATE TABLE TXN_LOG( 
txn_id NUMBER PRIMARY KEY,
txn_timestamp DATE DEFAULT SYSDATE,
from_acct_id NUMBER REFERENCES ACCOUNT(account_id),
to_acct_id NUMBER REFERENCES ACCOUNT(account_id),
txn_type VARCHAR2(10) DEFAULT 'CREATE' NOT NULL
    CHECK (txn_type IN ('CREATE', 'DEPOSIT', 'WITHDRAW', 'TRANSFER')),
amount NUMBER,
status VARCHAR2(10) DEFAULT 'SUCCESS' NOT NULL
    CHECK (status IN ('SUCCESS', 'FAILED')),
error_msg VARCHAR2(1000),
created_at DATE,
Last_modified_at DATE
);


/*
--Sequences: seq_account_id, seq_txn_id to generate keys.
CREATE SEQUENCE seq_account_id
START WITH
1 INCREMENT BY 1;

CREATE SEQUENCE seq_txn_id
START WITH
1 INCREMENT BY 1;
*/
--Optional index on txn_log.from_acct_id, txn_log.to_acct_id for quick history.
CREATE INDEX idx_from_acct_id
ON
txn_log (from_acct_id);

CREATE INDEX idx_to_acct_id
ON
txn_log (to_acct_id);
