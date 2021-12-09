

--DAwSQL Session -8 

--E-Commerce Project Solution



--1. Join all the tables and create a new table called combined_table. (market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)


SELECT *
INTO
combined_table
FROM
(
SELECT
cd.Cust_id, cd.Customer_Name, cd.Province, cd.Region, cd.Customer_Segment,
mf.Ord_id, mf.Prod_id, mf.Sales, mf.Discount, mf.Order_Quantity, mf.Product_Base_Margin,
od.Order_Date, od.Order_Priority,
pd.Product_Category, pd.Product_Sub_Category,
sd.Ship_id, sd.Ship_Mode, sd.Ship_Date
FROM market_fact mf
INNER JOIN cust_dimen cd ON mf.Cust_id = cd.Cust_id
INNER JOIN orders_dimen od ON od.Ord_id = mf.Ord_id
INNER JOIN prod_dimen pd ON pd.Prod_id = mf.Prod_id
INNER JOIN shipping_dimen sd ON sd.Ship_id = mf.Ship_id
) A;
select* from combined_table

--///////////////////////


--2. Find the top 3 customers who have the maximum count of orders.

select top 3 count(Order_ID) as Count_orders,Cust_id from combined_table group by  Cust_id order by count(Order_ID) desc;

SELECT	TOP(3)cust_id,customer_name, COUNT (Ord_id) as total_ord
FROM	combined_table
GROUP BY Cust_id, customer_name
ORDER BY total_ord desc



--/////////////////////////////////



--3.Create a new column at combined_table as DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.
--Use "ALTER TABLE", "UPDATE" etc.


Alter table combined_table
add DaystakenForDelivery int;

Update combined_table
Set DaysTakenForDelivery = DATEDIFF (day, Order_Date, Ship_Date)

select top 100 * from combined_table



--////////////////////////////////////


--4. Find the customer whose order took the maximum time to get delivered.
--Use "MAX" or "TOP"

SELECT Cust_id, Customer_Name, DaysTakenForDelivery
FROM combined_table
WHERE DaysTakenForDelivery=(SELECT MAX(DaysTakenForDelivery)
			    FROM combined_table)

SELECT top 1 Cust_id, Customer_Name, DaysTakenForDelivery
FROM combined_table
ORDER BY DaysTakenForDelivery desc;

--////////////////////////////////



--5. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011
--You can use such date functions and subqueries

SELECT MONTH(Order_date) AS MONTHLY, COUNT(DISTINCT Cust_id) AS MONTHLY_NUM_OF_CUST
FROM combined_table
WHERE cust_id IN
(
SELECT Cust_id
FROM combined_table
WHERE YEAR(Order_Date)=2011
AND MONTH(Order_Date)=1
)
AND YEAR (Order_Date) = 2011
GROUP BY MONTH(Order_date)
ORDER BY MONTHLY



--////////////////////////////////////////////


--6. write a query to return for each user the time elapsed between the first purchasing and the third purchasing, 
--in ascending order by Customer ID
--Use "MIN" with Window Functions

SELECT DISTINCT
		cust_id, order_date, dense_number, FIRST_ORDER_DATE, DATEDIFF(day, FIRST_ORDER_DATE, order_date) DAYS_ELAPSED
FROM	
		(
		SELECT	Cust_id, ord_id, order_Date,
				MIN (Order_Date) OVER (PARTITION BY cust_id) FIRST_ORDER_DATE,
				DENSE_RANK () OVER (PARTITION BY cust_id ORDER BY Order_date) dense_number
		FROM	combined_table
		) A
WHERE	dense_number = 3 
order by cust_id asc




WITH new_table 
AS (
    SELECT DISTINCT cust_id, order_date
    FROM combined_table
)
SELECT DISTINCT t4.cust_id, t4.first_order, t4.third_order,
DATEDIFF(DAY, (SELECT MIN(order_date) FROM combined_table), t4.third_order ) - 
DATEDIFF(DAY, (SELECT MIN(order_date) FROM combined_table), t4.first_order)
FROM
    (SELECT t3.cust_id, 
    CASE WHEN t3.birinci IS NOT NULL THEN t3.birinci ELSE LAG(t3.birinci) 
        OVER(PARTITION BY cust_id ORDER BY cust_id) END AS first_order,
    CASE WHEN t3.ucuncu IS NOT NULL THEN t3.ucuncu ELSE LEAD(t3.ucuncu) 
        OVER(PARTITION BY cust_id ORDER BY t3.ucuncu) END AS third_order
    FROM(
        SELECT t2.cust_id, t2.birinci, t2.ucuncu 
        FROM
            (SELECT cust_id, order_date,
            ROW_NUMBER() OVER(PARTITION BY cust_id ORDER BY order_date) AS third,
            CASE WHEN COUNT(order_date) OVER(PARTITION BY cust_id) >= 3 AND
            ROW_NUMBER() OVER(PARTITION BY cust_id ORDER BY order_date) = 1 THEN order_date ELSE NULL END AS birinci,
            CASE WHEN COUNT(order_date) OVER(PARTITION BY cust_id) >= 3 AND
            ROW_NUMBER() OVER(PARTITION BY cust_id ORDER BY order_date) = 3 THEN order_date ELSE NULL END AS ucuncu
            FROM new_table) AS t2
    WHERE t2.birinci IS NOT NULL OR t2.ucuncu IS NOT NULL) AS t3) AS t4
ORDER BY t4.cust_id 



--//////////////////////////////////////

--7. Write a query that returns customers who purchased both product 11 and product 14, 
--as well as the ratio of these products to the total number of products purchased by the customer.
--Use CASE Expression, CTE, CAST AND such Aggregate Functions



WITH T1 AS (
SELECT Cust_id, 
		SUM(CASE WHEN Prod_id = '11' THEN Order_Quantity ELSE 0 END) P11,
		SUM(CASE WHEN Prod_id = '14' THEN Order_Quantity ELSE 0 END) P14,
		SUM(Order_Quantity) TOTAL_PROD
FROM combined_table
GROUP BY Cust_id 
HAVING 
	    SUM(CASE WHEN Prod_id = '11' THEN Order_Quantity ELSE 0 END) >=1 AND
		SUM(CASE WHEN Prod_id = '14' THEN Order_Quantity ELSE 0 END) >=1
)
SELECT Cust_id, P11, P14, TOTAL_PROD,
	   ROUND(CAST( P11 as float)/CAST (TOTAL_PROD as float), 2) RATIO_P11,
	   ROUND(CAST( P14 as float)/CAST (TOTAL_PROD as float), 2) RATIO_P14
FROM T1
ORDER BY Cust_id;
 

--/////////////////


--CUSTOMER RETENTION ANALYSIS



--1. Create a view that keeps visit logs of customers on a monthly basis. (For each log, three field is kept: Cust_id, Year, Month)
--Use such date functions. Don't forget to call up columns you might need later.


CREATE VIEW customer_logs AS

SELECT cust_id,
				DATEPART(YEAR,Order_Date) AS [YEAR],
				DATEPART(MONTH, Order_date) AS [MONTH]

FROM combined_table

select * from customer_logs
order by 1,2,3





--//////////////////////////////////


--2. Create a view that keeps the number of monthly visits by users. (Separately for all months from the business beginning)
--Don't forget to call up columns you might need later.

CREATE VIEW NUMBER_OF_VISIT AS

SELECT Cust_id, [YEAR], [MONTH], COUNT(*) NUM_OF_LOG
FROM customer_logs
GROUP BY Cust_id, [YEAR],[MONTH]

select* from NUMBER_OF_VISIT
order by 1,2,3




--//////////////////////////////////


--3. For each visit of customers, create the next month of the visit as a separate column.
--You can number the months with "DENSE_RANK" function.
--then create a new column for each month showing the next month using the numbering you have made. (use "LEAD" function.)
--Don't forget to call up columns you might need later.

CREATE VIEW NEXT_VISIT_VW AS 
SELECT	*,		
LEAD ([MONTH]) OVER (PARTITION BY cust_id ORDER BY [MONTH]) NEXT_VISIT_MONTH
FROM customer_logs

select* from NEXT_VISIT_VW


--/////////////////////////////////



--4. Calculate the monthly time gap between two consecutive visits by each customer.
--Don't forget to call up columns you might need later.

CREATE VIEW monthly_time_gap AS
       SELECT *, NEXT_VISIT_MONTH-[MONTH] AS TimeGaps
       FROM NEXT_VISIT_VW


SELECT * From monthly_time_gap




--/////////////////////////////////////////


--5.Categorise customers using time gaps. Choose the most fitted labeling model for you.
--  For example: 
--	Labeled as churn if the customer hasn't made another purchase in the months since they made their first purchase.
--	Labeled as regular if the customer has made a purchase every month.
--  Etc.

SELECT cust_id, AVG_TIME_GAP,
		CASE
			WHEN AVG_TIME_GAP = 0 THEN 'Perfecto'
			WHEN AVG_TIME_GAP = 1 THEN 'retained'
			WHEN AVG_TIME_GAP >1 THEN 'irregular'
			WHEN AVG_TIME_GAP IS NULL THEN 'churned'
		ELSE 'UNKNOWN DATA' END CUST_CLASS
FROM
		(
		SELECT	cust_id, AVG (TimeGaps) AVG_TIME_GAP
		FROM	monthly_time_gap
		GROUP BY
				cust_id
		) A



--/////////////////////////////////////




--MONTH-WÝSE RETENTÝON RATE


--Find month-by-month customer retention rate  since the start of the business.


--1. Find the number of customers retained month-wise. (You can use time gaps)
--Use Time Gaps

SELECT *, COUNT(Cust_id) OVER(PARTITION BY [YEAR], [MONTH]) AS RetentionMonthWise
FROM monthly_time_gap
WHERE TimeGaps=1
ORDER BY Cust_id;



--//////////////////////


--2. Calculate the month-wise retention rate.

--Basic formula: o	Month-Wise Retention Rate = 1.0 * Total Number of Customers in The Previous Month / Number of Customers Retained in The Next Nonth

--It is easier to divide the operations into parts rather than in a single ad-hoc query. It is recommended to use View. 
--You can also use CTE or Subquery if you want.

--You should pay attention to the join type and join columns between your views or tables.

WITH CTE1 AS
     (SELECT [YEAR], [MONTH], COUNT(Cust_id) AS TotalCustomerPerMonth,
      SUM(CASE WHEN TimeGaps=1 THEN 1 END) AS RetentionMonthWise
      FROM monthly_time_gap
      GROUP BY [YEAR], [MONTH])
SELECT *
FROM(SELECT [YEAR], [MONTH], LAG(RetentionRate) OVER(ORDER BY [YEAR], [MONTH]) AS RetentionRate
     FROM(SELECT CTE1.[YEAR], CTE1.[MONTH],
		 ROUND(CAST(CTE1.RetentionMonthWise AS FLOAT) / CTE1.TotalCustomerPerMonth,2) AS RetentionRate
          FROM CTE1) AS SUBQ1) AS SUBQ2
WHERE RetentionRate IS NOT NULL





---///////////////////////////////////
--Good luck!