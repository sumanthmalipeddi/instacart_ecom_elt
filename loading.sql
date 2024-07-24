USE DATABASE DW_COURSE_DB;
USE SCHEMA INSTACART;

CREATE STAGE MY_STAGE
URL = "😈"
CREDENTIALS = (AWS_KEY_ID = '😈' 
AWS_SECRET_KEY = '😈');

CREATE OR REPLACE FILE FORMAT CSV_FILE_FORMAT
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"';

CREATE TABLE AISLES (
    AISLE_ID INTEGER PRIMARY KEY,
    AISLE VARCHAR
    );

SELECT * FROM AISLES;

COPY INTO AISLES (AISLE_ID, AISLE)
FROM @my_stage/aisles.csv
FILE_FORMAT = (FORMAT_NAME = 'csv_file_format');

SELECT * FROM AISLES;

CREATE TABLE DEPARTMENTS (
    DEPARTMENT_ID INTEGER PRIMARY KEY,
    DEPARTMENT VARCHAR
);

SELECT * FROM DEPARTMENTS;

COPY INTO DEPARTMENTS (DEPARTMENT_ID, DEPARTMENT)
FROM @my_stage/departments.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_FILE_FORMAT');

SELECT * FROM DEPARTMENTS;


CREATE TABLE PRODUCTS (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR,
    aisle_id INTEGER,
    department_id INTEGER,
    FOREIGN KEY (aisle_id) REFERENCES AISLES (aisle_id),
    FOREIGN KEY (department_id) REFERENCES DEPARTMENTS (department_id)
);

select * from products;

COPY INTO PRODUCTS (PRODUCT_ID,PRODUCT_NAME,AISLE_ID,DEPARTMENT_ID)
FROM @my_stage/products.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_FILE_FORMAT');

select COUNT(*) from products;

CREATE OR REPLACE TABLE ORDERS (
    order_id INTEGER PRIMARY KEY,
    user_id INTEGER,
    eval_set VARCHAR,
    order_number INTEGER,
    order_dow INTEGER,
    order_hour_of_day INTEGER,
    days_since_prior_order INTEGER
);

COPY INTO ORDERS (order_id,user_id,eval_set,order_number,order_dow,order_hour_of_day,days_since_prior_order)
FROM @my_stage/orders.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_FILE_FORMAT');

SELECT * FROM ORDERS LIMIT 10;

CREATE TABLE ORDER_PRODUCTS (
    order_id INTEGER,
    product_id INTEGER,
    add_to_cart_order INTEGER,
    reordered INTEGER,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

SELECT * FROM ORDER_PRODUCTS;

COPY INTO ORDER_PRODUCTS (order_id,product_id,add_to_cart_order,reordered)
FROM @my_stage/order_products.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_FILE_FORMAT');

SELECT * FROM ORDER_PRODUCTS LIMIT 10; 

    




























