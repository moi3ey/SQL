USE ORDERS;

/*Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms), 
 both first name and last name are in upper case, customer_email,  customer_creation_year 
 and display customer’s category after applying below categorization rules:
 i. if CUSTOMER_CREATION_DATE year <2005 then category A
 ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B 
 iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C
 Expected 52 rows in final output.
 [Note: TABLE to be used - ONLINE_CUSTOMER TABLE] 
Hint:Use CASE statement. create customer_creation_year column with the help of customer_creation_date,
 no permanent change in the table is required. (Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables
 for your representation. A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.) 
*/

## Answer 1.

SELECT 
    CUSTOMER_ID,
    (CONCAT(CASE CUSTOMER_GENDER
                WHEN 'M' THEN 'Mr'
                WHEN 'F' THEN 'Ms'
            END,
            ' ',
            UPPER(CUSTOMER_FNAME),
            ' ',
            UPPER(CUSTOMER_LNAME))) AS CUSTOMER_FULL_NAME,
    CUSTOMER_EMAIL,
    YEAR(CUSTOMER_CREATION_DATE) AS CUSTOMER_CREATION_YEAR,
    CASE
        WHEN YEAR(CUSTOMER_CREATION_DATE) < 2005 THEN 'A'
        WHEN
            2005 <= YEAR(CUSTOMER_CREATION_DATE)
                AND YEAR(CUSTOMER_CREATION_DATE) < 2011
        THEN
            'B'
        ELSE 'C'
    END AS CUSTOMER_CATEGORY
FROM
    ONLINE_CUSTOMER;

/* Q2. Write a query to display the following information for the products which
 have not been sold: product_id, product_desc, product_quantity_avail, product_price,
 inventory values (product_quantity_avail * product_price), New_Price after applying discount
 as per below criteria. Sort the output with respect to decreasing value of Inventory_Value. 
i) If Product Price > 20,000 then apply 20% discount 
ii) If Product Price > 10,000 then apply 15% discount 
iii) if Product Price =< 10,000 then apply 10% discount 
Expected 13 rows in final output.
[NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE]
Hint: Use CASE statement, no permanent change in table required. 
(Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables for your representation.
 A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.)
*/
## Answer 2.

SELECT 
    PRODUCT_ID,
    PRODUCT_DESC,
    PRODUCT_QUANTITY_AVAIL,
    PRODUCT_PRICE,
    (PRODUCT_QUANTITY_AVAIL * PRODUCT_PRICE) AS INVENTORY_PRICE,
    CASE
        WHEN PRODUCT_PRICE > 20000 THEN ROUND(PRODUCT_PRICE * 0.8, 2)
        WHEN PRODUCT_PRICE > 10000 THEN ROUND(PRODUCT_PRICE * 0.85, 2)
        WHEN PRODUCT_PRICE <= 10000 THEN ROUND(PRODUCT_PRICE * 0.9, 2)
    END AS NEW_PRICE
FROM
    PRODUCT
        LEFT JOIN
    ORDER_ITEMS USING (PRODUCT_ID)
WHERE
    ORDER_ID IS NULL;

/*Q3. Write a query to display Product_class_code, Product_class_desc, Count of Product type in each product class, 
Inventory Value (p.product_quantity_avail*p.product_price). Information should be displayed for only those
 product_class_code which have more than 1,00,000 Inventory Value. Sort the output with respect to decreasing value of Inventory_Value. 
Expected 9 rows in final output.
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS]
Hint: 'count of product type in each product class' is the count of product_id based on product_class_code.
*/

## Answer 3.

SELECT 
    PRODUCT_CLASS_CODE,
    PRODUCT_CLASS_DESC,
    SUM(PRODUCT_QUANTITY_AVAIL * PRODUCT_PRICE) AS INVENTORY_VALUE,
    COUNT(PRODUCT_ID) AS COUNT_OF_PRODUCT_TYPE
FROM
    PRODUCT
        JOIN
    PRODUCT_CLASS USING (PRODUCT_CLASS_CODE)
GROUP BY 1 , 2
HAVING INVENTORY_VALUE > 100000
ORDER BY 3 DESC;


/* Q4. Write a query to display customer_id, full name, customer_email, customer_phone and
 country of customers who have cancelled all the orders placed by them.
Expected 1 row in the final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, OREDER_HEADER]
Hint: USE SUBQUERY
*/
## Answer 4.

SELECT 
    CUSTOMER_ID,
    CONCAT(UPPER(CUSTOMER_FNAME),
            ' ',
            UPPER(CUSTOMER_LNAME)) FULL_NAME,
    CUSTOMER_EMAIL,
    CUSTOMER_PHONE,
    COUNTRY
FROM
    ONLINE_CUSTOMER
        JOIN
    ADDRESS USING (ADDRESS_ID)
WHERE
    CUSTOMER_ID IN (SELECT DISTINCT
            OH.CUSTOMER_ID
        FROM
            ORDER_HEADER OH
                JOIN
            ONLINE_CUSTOMER ON ONLINE_CUSTOMER.CUSTOMER_ID = OH.CUSTOMER_ID
                AND NOT EXISTS( SELECT 
                    1
                FROM
                    ORDER_HEADER OH1
                WHERE
                    OH.CUSTOMER_ID = OH1.CUSTOMER_ID
                        AND OH1.ORDER_STATUS != 'Cancelled'));

/*Q5. Write a query to display Shipper name, City to which it is catering, num of customer catered by the shipper in the city ,
 number of consignment delivered to that city for Shipper DHL 
Expected 9 rows in the final output
[NOTE: TABLES to be used - SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
Hint: The answer should only be based on Shipper_Name -- DHL. The main intent is to find the number
 of customers and the consignments catered by DHL in each city.
 */

## Answer 5.  
SELECT 
    SHIPPER_NAME,
    CITY,
    COUNT(CUSTOMER_ID) NO_OF_CUSTOMERS,
    COUNT(ORDER_status) NO_OF_CONSIGNMENT
FROM
    SHIPPER
        JOIN
    ORDER_HEADER USING (SHIPPER_ID)
        JOIN
    ONLINE_CUSTOMER USING (CUSTOMER_ID)
        JOIN
    ADDRESS USING (ADDRESS_ID)
WHERE
    SHIPPER_NAME = 'DHL'
        AND ORDER_STATUS = 'SHIPPED'
GROUP BY CITY;
              
/*Q6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold and 
show inventory Status of products as per below condition: 

a. For Electronics and Computer categories, 
if sales till date is Zero then show  'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 10% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 50% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' 

b. For Mobiles and Watches categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 20% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, need to add some inventory', 
if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory' 

c. Rest of the categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 30% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory'
Expected 60 rows in final output
[NOTE: (USE CASE statement) ; TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS]
Hint:  quantity sold here is product_quantity in order_items table. 
You may use multiple case statements to show inventory status (Low stock, In stock, and Enough stock)
 that meets both the conditions i.e. on products as well as on quantity.
The meaning of the rest of the categories, means products apart from electronics, computers, mobiles, and watches.
*/

## Answer 6.

SELECT 
    P.PRODUCT_ID,
    P.PRODUCT_DESC,
    P.PRODUCT_QUANTITY_AVAIL,
    PO.QUANTITY_SOLD,
    CASE
        WHEN
            PC.PRODUCT_CLASS_DESC IN ('ELECTRONICS' , 'COMPUTER')
        THEN
            CASE
                WHEN PO.QUANTITY_SOLD = 0 THEN 'No Sales in past, give discount to reduce inventory'
                WHEN P.PRODUCT_QUANTITY_AVAIL < (PO.QUANTITY_SOLD * 0.10) THEN 'Low inventory, need to add inventory'
                WHEN P.PRODUCT_QUANTITY_AVAIL >= (PO.QUANTITY_SOLD * 0.50) THEN 'Sufficient inventory'
            END
        WHEN
            PC.PRODUCT_CLASS_DESC IN ('MOBILES' , 'WATCHES')
        THEN
            CASE
                WHEN PO.QUANTITY_SOLD = 0 THEN 'No Sales in past, give discount to reduce inventory'
                WHEN P.PRODUCT_QUANTITY_AVAIL < (PO.QUANTITY_SOLD * 0.20) THEN 'Low inventory, need to add inventory'
                WHEN P.PRODUCT_QUANTITY_AVAIL >= (PO.QUANTITY_SOLD * 0.60) THEN 'Sufficient inventory'
            END
        ELSE CASE
            WHEN PO.QUANTITY_SOLD = 0 THEN 'No Sales in past, give discount to reduce inventory'
            WHEN P.PRODUCT_QUANTITY_AVAIL < (PO.QUANTITY_SOLD * 0.30) THEN 'Low inventory, need to add inventory'
            WHEN P.PRODUCT_QUANTITY_AVAIL >= (PO.QUANTITY_SOLD * 0.70) THEN 'Sufficient inventory'
        END
    END AS INVENTORY_STATUS
FROM
    PRODUCT P
        INNER JOIN
    (SELECT 
        PR.PRODUCT_ID,
            PR.PRODUCT_DESC,
            SUM(COALESCE(OI.PRODUCT_QUANTITY, 0)) QUANTITY_SOLD
    FROM
        PRODUCT PR
    LEFT JOIN ORDER_ITEMS OI ON PR.PRODUCT_ID = OI.PRODUCT_ID
    GROUP BY PR.PRODUCT_ID , PR.PRODUCT_DESC) PO ON P.PRODUCT_ID = PO.PRODUCT_ID
        INNER JOIN
    PRODUCT_CLASS PC ON P.PRODUCT_CLASS_CODE = PC.PRODUCT_CLASS_CODE;

/* Q7. Write a query to display order_id and volume of the biggest order (in terms of volume) that can fit in carton id 10 .
Expected 1 row in final output
[NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT]
Hint: First find the volume of carton id 10 and then find the order id with products having total volume less than the volume of carton id 10
 */

## Answer 7.

SELECT ORDER_ID, sum(PRODUCT_QUANTITY * LEN * HEIGHT * WIDTH) AS VOLUME
FROM ORDER_ITEMS JOIN PRODUCT USING (PRODUCT_ID)
WHERE  
PRODUCT_QUANTITY * LEN * HEIGHT * WIDTH <= 
(SELECT (LEN * HEIGHT * WIDTH) AS VOLUME FROM CARTON WHERE CARTON_ID = 10)
Group by 1
ORDER BY 2 DESC
LIMIT 1;
SELECT ORDER_ID, VOLUME FROM (SELECT ORDER_ID, sum(PRODUCT_QUANTITY * LEN * HEIGHT * WIDTH) AS VOLUME
FROM ORDER_ITEMS JOIN PRODUCT USING (PRODUCT_ID)
group by 1 order by 2 desc) CART HAVING CART.VOLUME <= ( SELECT (LEN*HEIGHT * WIDTH) AS CART_VOLUME FROM CARTON WHERE CARTON_ID = 10) ORDER BY 2 DESC LIMIT 1;

SELECT ORDER_ID
,VOLUME FROM (
SELECT OI.ORDER_ID
,SUM(P.LEN * P.WIDTH * P.HEIGHT * OI.PRODUCT_QUANTITY) AS VOLUME
FROM ORDER_ITEMS OI
INNER JOIN PRODUCT P ON OI.PRODUCT_ID = P.PRODUCT_ID
GROUP BY OI.ORDER_ID
ORDER BY VOLUME
) TAB
HAVING TAB.VOLUME <= (
SELECT (LEN * WIDTH * HEIGHT) AS CARTON_VOL
FROM CARTON
WHERE CARTON_ID = 10
)
ORDER BY VOLUME DESC LIMIT 1;



/*Q8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) 
shipped where mode of payment is Cash and customer last name starts with 'G'
Expected 2 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
*/

## Answer 8.

SELECT 
    CUSTOMER_ID,
    CONCAT(CUSTOMER_FNAME, ' ', CUSTOMER_LNAME) AS FULL_NAME,
    SUM(PRODUCT_QUANTITY) AS TOTAL_QUANTITY,
    SUM(PRODUCT_QUANTITY * PRODUCT_PRICE) AS TOTAL_VALUE
FROM
    ONLINE_CUSTOMER
        INNER JOIN
    ORDER_HEADER USING (CUSTOMER_ID)
        INNER JOIN
    ORDER_ITEMS USING (ORDER_ID)
        INNER JOIN
    PRODUCT P USING (PRODUCT_ID)
WHERE
    ORDER_STATUS = 'Shipped'
        AND PAYMENT_MODE = 'Cash'
        AND CUSTOMER_LNAME LIKE 'G%'
GROUP BY CUSTOMER_ID
ORDER BY 3 DESC;



/*Q9. Write a query to display product_id, product_desc and total quantity of products which are sold together 
with product id 201 and are not shipped to city Bangalore and New Delhi. 
Expected 5 rows in final output
[NOTE: TABLES to be used - ORDER_ITEMS, PRODUCT, ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
Hint: Display the output in descending order with respect to the sum of product_quantity. 
(USE SUB-QUERY) In final output show only those products , 
 product_id’s which are sold with 201 product_id (201 should not be there in output) and are shipped except Bangalore and New Delhi
 */

## Answer 9.

SELECT 
    PRODUCT_ID,
    PRODUCT_DESC,
    SUM(PRODUCT_QUANTITY) AS TOTAL_QUANTITY
FROM
    PRODUCT
        JOIN
    ORDER_ITEMS USING (PRODUCT_ID)
WHERE
    PRODUCT_ID != 201
        AND ORDER_ID IN (SELECT DISTINCT
            ORDER_ID
        FROM
            ORDER_ITEMS
                JOIN
            ORDER_HEADER USING (ORDER_ID)
                JOIN
            ONLINE_CUSTOMER USING (CUSTOMER_ID)
                JOIN
            ADDRESS USING (ADDRESS_ID)
        WHERE
            (PRODUCT_ID = 201)
                AND CITY NOT IN ('Bangalore' , 'New Delhi')
                AND ORDER_STATUS = 'Shipped')
GROUP BY 1 , 2
ORDER BY 3 DESC;



/* Q10. Write a query to display the order_id, customer_id and customer fullname, 
total quantity of products shipped for order ids which are even and 
shipped to address where pincode is not starting with "5" 
Expected 15 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_HEADER, ORDER_ITEMS, ADDRESS]	
 */
## Answer 10.

SELECT 
    ORDER_ID,
    CUSTOMER_ID,
    CONCAT(UPPER(CUSTOMER_FNAME),
            ' ',
            UPPER(CUSTOMER_LNAME)) AS FULL_NAME,
    SUM(PRODUCT_QUANTITY) AS TOTAL_QUANTITY
FROM
    ORDER_ITEMS
        JOIN
    ORDER_HEADER USING (ORDER_ID)
        JOIN
    ONLINE_CUSTOMER USING (CUSTOMER_ID)
        JOIN
    ADDRESS USING (ADDRESS_ID)
WHERE
    ORDER_ID % 2 = 0
        AND PINCODE NOT LIKE '5%'
        AND ORDER_STATUS = 'SHIPPED'
GROUP BY 1
ORDER BY 4 DESC;
