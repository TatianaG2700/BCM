describe xxbcm_order_mgt;
select * from xxbcm_order_mgt;

-- STANDARDIZING THE DATES [ enables to set the date in ascending order]
UPDATE xxbcm_order_mgt
SET ORDER_DATE = CASE
    WHEN ORDER_DATE REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' THEN STR_TO_DATE(ORDER_DATE, '%d-%m-%Y')
    WHEN ORDER_DATE REGEXP '^[0-9]{2}-[A-Z]{3}-[0-9]{4}$' THEN STR_TO_DATE(ORDER_DATE, '%d-%b-%Y')
    ELSE ORDER_DATE
END, 
INVOICE_DATE = CASE
     WHEN INVOICE_DATE REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' THEN STR_TO_DATE(INVOICE_DATE, '%d-%m-%Y')
     WHEN INVOICE_DATE REGEXP '^[0-9]{2}-[A-Z]{3}-[0-9]{4}$' THEN STR_TO_DATE(INVOICE_DATE, '%d-%b-%Y')
     ELSE INVOICE_DATE
END;


-- STANDARDIZING ORDER_TOTAL_AMOUNT, ORDER_LINE_AMOUNT, INVOICE_AMOUNT, SUPP_CONTACT_NUMBER
UPDATE xxbcm_order_mgt
SET ORDER_TOTAL_AMOUNT = REPLACE(REPLACE(REPLACE(ORDER_TOTAL_AMOUNT, 'o', '0'), 'S', '5'), 'I', '1'),
ORDER_LINE_AMOUNT = REPLACE(REPLACE(REPLACE(ORDER_LINE_AMOUNT, 'o', '0'), 'S', '5'), 'I', '1'),
INVOICE_AMOUNT = REPLACE(REPLACE(REPLACE(INVOICE_AMOUNT, 'o', '0'), 'S', '5'), 'I', '1'),
SUPP_CONTACT_NUMBER = REPLACE(REPLACE(REPLACE(SUPP_CONTACT_NUMBER, 'o', '0'), 'S', '5'), 'I', '1');

-- STANDARDIZING SUPP_CONTACT_NUMBER REMOVING SPACES IN BETWEEN NUMBERS AND DOTS

UPDATE xxbcm_order_mgt
SET SUPP_CONTACT_NUMBER = REPLACE(REPLACE(SUPP_CONTACT_NUMBER, '.', ''), '.', '');


-- CREATION OF SUPPLIERS TABLE
CREATE TABLE Suppliers (
    ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    SUPPLIER_NAME VARCHAR(255),
    SUPP_CONTACT_NAME VARCHAR(255),
    SUPP_ADDRESS VARCHAR(255),
    SUPP_CONTACT_NUMBER VARCHAR(20),
    SUPP_CONTACT_ALT_NUMBER VARCHAR(20),
    SUPP_EMAIL VARCHAR(100)
);

-- LOADING INIT VALUES TO SUPPLIERS TABLE
INSERT INTO Suppliers (SUPPLIER_NAME, SUPP_CONTACT_NAME, SUPP_ADDRESS, SUPP_EMAIL, SUPP_CONTACT_NUMBER, SUPP_CONTACT_ALT_NUMBER)
SELECT DISTINCT
	SUPPLIER_NAME,
    SUPP_CONTACT_NAME,
    SUPP_ADDRESS,
    SUPP_EMAIL,
    TRIM(SUBSTRING_INDEX(SUPP_CONTACT_NUMBER, ',', 1)) AS SUPP_CONTACT_NUMBER,
    TRIM(SUBSTRING_INDEX(SUPP_CONTACT_NUMBER, ',', -1)) AS SUPP_CONTACT_ALT_NUMBER
FROM xxbcm_order_mgt;

-- Create OrdersDetail table
CREATE TABLE OrdersDetail (
    ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ORDER_REF VARCHAR(50),
    ORDER_DATE DATE,
    ORDER_TOTAL_AMOUNT VARCHAR(255),
    ORDER_DESCRIPTION VARCHAR(255),
    ORDER_STATUS VARCHAR(20),
    ORDER_LINE_AMOUNT VARCHAR(255),
	SUPPLIER_ID INT REFERENCES Suppliers(ID)
);


-- LOADING ORDERDETAILS TABLE
INSERT INTO OrdersDetail (ORDER_REF, ORDER_DATE, ORDER_TOTAL_AMOUNT, ORDER_DESCRIPTION, ORDER_STATUS, ORDER_LINE_AMOUNT, SUPPLIER_ID)
SELECT 
	   ORDER_REF,
    ORDER_DATE,
    ORDER_TOTAL_AMOUNT,
    ORDER_DESCRIPTION,
    ORDER_STATUS,
    ORDER_LINE_AMOUNT,
    t2.ID AS SUPPLIER_ID
FROM xxbcm_order_mgt t1
LEFT JOIN Suppliers t2
ON t1.SUPPLIER_NAME = t2.SUPPLIER_NAME;


-- Create Invoices table
CREATE TABLE Invoices (
    ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    INVOICE_REFERENCE VARCHAR(50),
    INVOICE_Description varchar(500),
    INVOICE_DATE DATE,
    INVOICE_STATUS VARCHAR(20),
    INVOICE_HOLD_REASON VARCHAR(255),
    INVOICE_AMOUNT varchar(20),
	ORDER_ID INT REFERENCES OrdersDetail(ID)
    
);

-- INSERTING DATA IN THE INVOICE TABLE --
INSERT INTO Invoices (INVOICE_REFERENCE, INVOICE_Description, INVOICE_DATE, INVOICE_STATUS, INVOICE_HOLD_REASON, INVOICE_AMOUNT, ORDER_ID )
	SELECT 
    t1.INVOICE_REFERENCE,
    t1.INVOICE_DESCRIPTION,
    t1.INVOICE_DATE,
    t1.INVOICE_STATUS,
    t1.INVOICE_HOLD_REASON,
    t1.INVOICE_AMOUNT,
    t2.ID AS ORDER_ID
FROM xxbcm_order_mgt t1
LEFT JOIN  Invoices t2
ON t1.INVOICE_STATUS = t2.INVOICE_STATUS;


