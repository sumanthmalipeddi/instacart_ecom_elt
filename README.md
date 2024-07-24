# Instacart - ELT - Data Engineering Project
## Story Line:
**Client:** The Kaggle has uploaded an anonymous Instacart data set for solving a specific machine learning competition. We need to get data stored in snowflake data warehouse with complete transformations to fact and dimension tables. 
<br>**Developer:** We can use SQL transformation by CTAS statements and provide in snowflake. Where does the data present right now.
<br> **Client:** You need to import from AWS S3 bucket the following access id and keys will be provided.
<br> **Developer:** Ok.
# Architecture
![Main](https://github.com/sumanthmalipeddi/instacart_ecom_elt/blob/main/instacart.drawio.png)
# Technology Used
* Programming Language - SQL
* Amazon Web Services Cloud Platform
  * AWS S3: Store and retrieve data securely at any scale, with high availability and durability.
* Snowflake 
# Data Base Used
Kaggle - [Instacart Market Basket Analysis](https://www.kaggle.com/competitions/instacart-market-basket-analysis/data)
 

```
#For Snowflake Worksheet Code Implementation
```

### Important Note: Never Disclose your cliend_id and cliend_secret ( In the configurations we can add environmental variables for secured usage)
![Main](https://github.com/sumanthmalipeddi/instacart_ecom_elt/blob/main/instakart_kaggle.drawio.png)
## Data Loading
```
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
```
# Data Transformation
![Main](https://github.com/sumanthmalipeddi/instacart_ecom_elt/blob/main/Instacart_Fact_Dim_Modeling.drawio.png)
```
--WRITING FACT AND DIMENSION TABLE
--USING CTAS QUERY

USE DATABASE DW_COURSE_DB;
USE SCHEMA INSTACART;

CREATE OR REPLACE TABLE DIM_USERS AS (
    SELECT
        USER_ID
    FROM 
        ORDERS
);

CREATE OR REPLACE TABLE DIM_PRODUCTS AS (
    SELECT 
        PRODUCT_ID, 
        PRODUCT_NAME
    FROM 
        PRODUCTS  
);

CREATE OR REPLACE TABLE DIM_DEPARTMENTS AS (
    SELECT 
        DEPARTMENT_ID,
        DEPARTMENT
    FROM 
        DEPARTMENTS
);

CREATE OR REPLACE TABLE DIM_AISLES AS (
    SELECT
        AISLE_ID,
        AISLE
    FROM
        AISLES
);

CREATE OR REPLACE TABLE DIM_ORDER AS (
    SELECT 
        ORDER_ID,
        ORDER_NUMBER,
        ORDER_DOW,
        ORDER_HOUR_OF_DAY,
        DAYS_SINCE_PRIOR_ORDER
    FROM
        ORDERS
);

CREATE OR REPLACE TABLE FACT_ORDER_PRODUCTS AS (
    SELECT 
        OP.ORDER_ID,
        OP.PRODUCT_ID,
        O.USER_ID,
        P.DEPARTMENT_ID,
        P.AISLE_ID,
        OP.ADD_TO_CART_ORDER,
        OP.REORDERED
    FROM
        ORDER_PRODUCTS OP
    JOIN 
        ORDERS O ON OP.ORDER_ID = O.ORDER_ID
    JOIN 
        PRODUCTS P ON OP.PRODUCT_ID = P.PRODUCT_ID
);

CREATE TABLE fact_order_products AS (
  SELECT
    op.order_id,
    op.product_id,
    o.user_id,
    p.department_id,
    p.aisle_id,
    op.add_to_cart_order,
    op.reordered
  FROM
    order_products op
  JOIN
    orders o ON op.order_id = o.order_id
  JOIN
    products p ON op.product_id = p.product_id
);

USE DATABASE DW_COURSE_DB;
USE SCHEMA INSTACART_DIM_FACT;


CREATE TABLE DW_COURSE_DB.INSTACART_DIM_FACT.DIM_AISLES CLONE DW_COURSE_DB.INSTACART.DIM_AISLES;
CREATE TABLE DW_COURSE_DB.INSTACART_DIM_FACT.DIM_DEPARTMENTS CLONE DW_COURSE_DB.INSTACART.DIM_DEPARTMENTS;
CREATE TABLE DW_COURSE_DB.INSTACART_DIM_FACT.DIM_ORDER CLONE DW_COURSE_DB.INSTACART.DIM_ORDER;
CREATE TABLE DW_COURSE_DB.INSTACART_DIM_FACT.DIM_PRODUCTS CLONE DW_COURSE_DB.INSTACART.DIM_PRODUCTS;
CREATE TABLE DW_COURSE_DB.INSTACART_DIM_FACT.DIM_USERS CLONE DW_COURSE_DB.INSTACART.DIM_USERS;
CREATE TABLE DW_COURSE_DB.INSTACART_DIM_FACT.FACT_ORDER_PRODUCTS CLONE DW_COURSE_DB.INSTACART.FACT_ORDER_PRODUCTS;

USE DATABASE DW_COURSE_DB;
USE SCHEMA INSTACART;

DROP TABLE DW_COURSE_DB.INSTACART.DIM_AISLES;
DROP TABLE DW_COURSE_DB.INSTACART.DIM_DEPARTMENTS;
DROP TABLE DW_COURSE_DB.INSTACART.DIM_ORDER;
DROP TABLE DW_COURSE_DB.INSTACART.DIM_PRODUCTS;
DROP TABLE DW_COURSE_DB.INSTACART.DIM_USERS;
DROP TABLE DW_COURSE_DB.INSTACART.ORDER_PRODUCTS;
UNDROP TABLE DW_COURSE_DB.INSTACART.ORDER_PRODUCTS;

DROP TABLE DW_COURSE_DB.INSTACART.FACT_ORDER_PRODUCTS;

SELECT * FROM DW_COURSE_DB.INSTACART_DIM_FACT.FACT_ORDER_PRODUCTS LIMIT 10;
```
# Snowflake Preview
![Main](https://github.com/sumanthmalipeddi/instacart_ecom_elt/blob/main/analytics.JPG)




### Here, the Successful retrieval of Data from the tables closes the Data Engineering Part. The tables can be used for Machine Learning Purposes. 
