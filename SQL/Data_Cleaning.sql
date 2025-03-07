-- Preview the Cleaned_data Table
SELECT *
FROM platinum-goods-452923-t1.SuperSell.Cleaned_data;


SELECT DISTINCT CITY, REGION, STATE, COUNTRY
FROM platinum-goods-452923-t1.SuperSell.Cleaned_data;

-- 1- Stucturing Table with additional Features 
  -- ADD NEW FEATURE LOCATION_ID
    -- Adding the column
      ALTER TABLE platinum-goods-452923-t1.SuperSell.Cleaned_data
      ADD COLUMN LOCATION_ID STRING;

    -- Updating the 'LOCATION_ID' column with the 
      UPDATE platinum-goods-452923-t1.SuperSell.Cleaned_data
      SET LOCATION_ID = CONCAT(LEFT(COUNTRY, 3),'_',LEFT(REGION, 3),'_',CITY)
      WHERE TRUE;

    SELECT DISTINCT SHIP_DATE, Ship_Mode,Shipping_Cost
    FROM platinum-goods-452923-t1.SuperSell.Cleaned_data;

  -- ADD NEW FEATURE SHIP_ID
    -- Adding the column
      ALTER TABLE platinum-goods-452923-t1.SuperSell.Cleaned_data
      ADD COLUMN SHIP_ID STRING NOT NULL;

    -- Updating the 'SHIP_ID' column with the first 3 letters from Ship_Mode and ROW_ID
      UPDATE platinum-goods-452923-t1.SuperSell.Cleaned_data
      SET SHIP_ID = CONCAT(LEFT(Ship_Mode, 3), '_', ROW_ID)
      WHERE TRUE;


-- 2- Missing Values
  -- CHECK If there is Missing Values
    SELECT 
      COUNT(*) AS Total_Rows,
      COUNTIF(Customer_ID IS NULL) AS Missing_Cust_ID,
      COUNTIF(Product_ID IS NULL) AS Missing_PID,
      COUNTIF(Location_ID IS NULL) AS Missing_Location_ID,
      COUNTIF(Ship_ID IS NULL) AS Missing_Ship_ID
    FROM platinum-goods-452923-t1.SuperSell.Cleaned_data;

  -- There is none so Lets skip to the next process

-- 3- Capitalization of String Values such as Customer_Name,CATEGORY,City,Region and Country
    UPDATE platinum-goods-452923-t1.SuperSell.Cleaned_data
    SET CUSTOMER_NAME = UPPER(CUSTOMER_NAME),
        CATEGORY = UPPER(CATEGORY),
        CITY = UPPER(CITY),
        REGION = UPPER(REGION),
        COUNTRY = UPPER(COUNTRY)
      WHERE TRUE;

-- 4- Check And If available Fix Ivalid Values
  -- Checking if there is negavive values in Sales, Quantity and
    SELECT Sales, Quantity,Shipping_Cost
    FROM platinum-goods-452923-t1.SuperSell.Cleaned_data
    WHERE Sales<0 OR Quantity<0 or SHIPPING_COST<0;

  -- IF It was available it can be fixed as
    UPDATE platinum-goods-452923-t1.SuperSell.Cleaned_data
    SET SALES = ABS(SALES),
        SHIPPING_COST = ABS(SHIPPING_COST),
        QUANTITY = ABS(QUANTITY)
    WHERE SALES < 0 OR SHIPPING_COST < 0 OR QUANTITY < 0;

-- 5- Normalizing the Data : CREATING 5 DIFFERENT TABLES FROM THE CLEANED_DATA TABLE
  
  -- A- ORDERS TABLE
    CREATE TABLE platinum-goods-452923-t1.SuperSell.ORDERS AS 
    (
      SELECT ROW_ID, ORDER_ID, ORDER_DATE, CUSTOMER_ID, PRODUCT_ID,SHIP_ID,
      LOCATION_ID, MARKET, SALES, QUANTITY, DISCOUNT, PROFIT, ORDER_PRIORITY
      FROM platinum-goods-452923-t1.SuperSell.Cleaned_data
      ORDER BY ROW_ID
    );

    SELECT *
    FROM platinum-goods-452923-t1.SuperSell.ORDERS;

  -- B- CUSTOMERS TABLE
    -- First Lets Check if a Customer has more than 1 customer ID
        SELECT Customer_Name, COUNT(DISTINCT Customer_ID) AS ID_Count
        FROM platinum-goods-452923-t1.SuperSell.Cleaned_data
        GROUP BY Customer_Name
        HAVING COUNT(DISTINCT Customer_ID) > 1;

    -- So Lets fix it by assignining the earliest customer id to each customer name

        UPDATE platinum-goods-452923-t1.SuperSell.Cleaned_data AS C1
        SET Customer_ID = 
        (
            SELECT MIN(C2.Customer_ID)
            FROM platinum-goods-452923-t1.SuperSell.Cleaned_data AS C2
            WHERE C2.Customer_Name = C1.Customer_Name
        )
        WHERE Customer_Name IN 
        (
            SELECT Customer_Name
            FROM platinum-goods-452923-t1.SuperSell.Cleaned_data
            GROUP BY Customer_Name
            HAVING COUNT(DISTINCT Customer_ID) > 1
        );

    -- Creating the CUSTOMERS TABLE from the Values of Cleaned_data Table
        CREATE TABLE platinum-goods-452923-t1.SuperSell.CUSTOMERS AS 
        (
          SELECT DISTINCT CUSTOMER_ID, CUSTOMER_NAME,SEGMENT
          FROM platinum-goods-452923-t1.SuperSell.Cleaned_data
          ORDER BY Customer_Name
        );

        SELECT *
        FROM platinum-goods-452923-t1.SuperSell.CUSTOMERS; 

  -- C- PRODUCTS TABLE
    -- Lets Check if a PRODUCT has more than 1 PRODUCT_ID
      SELECT PRODUCT_NAME, COUNT(DISTINCT PRODUCT_ID) AS ID_Count
      FROM platinum-goods-452923-t1.SuperSell.Cleaned_data
      GROUP BY PRODUCT_NAME
      HAVING COUNT(DISTINCT PRODUCT_ID) > 1;

    -- So Lets fix it by assignining the earliest product id to each product name

      UPDATE platinum-goods-452923-t1.SuperSell.Cleaned_data AS P1
      SET PRODUCT_ID = 
      (
          SELECT MIN(P2.PRODUCT_ID)
          FROM platinum-goods-452923-t1.SuperSell.Cleaned_data AS P2
          WHERE P1.PRODUCT_NAME = P2.PRODUCT_NAME
      )
      WHERE PRODUCT_NAME IN 
      (
          SELECT PRODUCT_NAME
          FROM platinum-goods-452923-t1.SuperSell.Cleaned_data
          GROUP BY PRODUCT_NAME
          HAVING COUNT(DISTINCT PRODUCT_ID) > 1
      );

      -- Creating the PRODUCTS TABLE from the Values of Cleaned_data Table

      CREATE TABLE platinum-goods-452923-t1.SuperSell.PRODUCTS AS 
      (
        SELECT DISTINCT PRODUCT_ID,PRODUCT_NAME, CATEGORY, SUB_CATEGORY
        FROM platinum-goods-452923-t1.SuperSell.Cleaned_data
        ORDER BY PRODUCT_ID
      );

      SELECT *
      FROM platinum-goods-452923-t1.SuperSell.PRODUCTS; 

  -- D- LOCATION TABLE
    CREATE TABLE platinum-goods-452923-t1.SuperSell.LOCATION AS 
    (
      SELECT DISTINCT Location_ID, CITY, STATE, REGION, COUNTRY
      FROM platinum-goods-452923-t1.SuperSell.Cleaned_data
      ORDER BY Location_ID
    );

    SELECT *
    FROM platinum-goods-452923-t1.SuperSell.LOCATION; 

  -- E- SHIPMENT TABLE
    CREATE TABLE platinum-goods-452923-t1.SuperSell.SHIPMENT AS 
    (
      SELECT SHIP_ID, SHIP_DATE, Ship_Mode,Shipping_Cost
      FROM platinum-goods-452923-t1.SuperSell.Cleaned_data
      ORDER BY SHIP_DATE
    );

    SELECT * 
    FROM platinum-goods-452923-t1.SuperSell.SHIPMENT;
