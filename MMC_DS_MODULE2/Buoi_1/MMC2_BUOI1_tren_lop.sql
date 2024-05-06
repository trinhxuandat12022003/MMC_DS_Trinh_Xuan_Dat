CREATE DATABASE Sale_Management;
USE Sale_Management ;
CREATE TABLE Customers(
    customer_id             INT,
    first_name              VARCHAR(50),
    email_address           VARCHAR(50),
    number_of_complaints    INT
);

CREATE TABLE SALES(
    purchase_number         INT,
    date_of_purchase        DATE,
    customer_id             INT,
    item_code               VARCHAR(50)   
);

CREATE TABLE Items(
    Item_code                   VARCHAR(50),
    Item                        VARCHAR(50),
    unit_price_usd              INT,
    company_id                  INT,
    company                     VARCHAR(50),
    headquarter_phone_number    VARCHAR(50)
);
