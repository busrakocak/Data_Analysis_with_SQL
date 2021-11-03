
SELECT	C.brand_name as Brand, D.category_name as Category, B.model_year as Model_Year,
		ROUND (SUM (A.quantity * A.list_price * (1 - A.discount)), 0) total_sales_price

FROM	sale.order_item A, product.product B, product.brand C, product.category D
WHERE	A.product_id = B.product_id
AND		B.brand_id = C.brand_id
AND		B.category_id = D.category_id
GROUP BY
		C.brand_name, D.category_name, B.model_year


SELECT Brand, Category, Model_Year, sum(total_sales_price) total_price
FROM sale.sales_summary
GROUP BY
       ROLLUP (Brand, Category, Model_Year)


--Hocanýn derste çözdüðü bir soru bu: 

SELECT order_id, 
		(SELECT SUM(list_price) FROM sale.order_item AS B WHERE A.order_id = B.order_id )
FROM sale.order_item AS A

SELECT DISTINCT order_id, 
		(SELECT SUM(list_price) FROM sale.order_item AS B WHERE A.order_id = B.order_id )
FROM sale.order_item AS A  --Distinct yazmak tekrar eden þeyleri elemek için kullanýldý.

--Mehmet abinin alternatif çözümü
SELECT order_id , SUM(list_price)
FROM sale.order_item
GROUP BY order_id;

--yeni soru: Maranýn çalýþtýðý maðazadaki personelleri listeleyin

SELECT first_name, last_name
FROM sale.staff
WHERE store_id = ( SELECT store_id
                  FROM sale.staff
                  WHERE first_name ='Maria' AND last_name ='Cussona')

--Jane'in menajer olduðu listenin çalýþanlarýný getirin
SELECT *
FROM sale.staff

SELECT *
FROM  sale.staff
WHERE manager_id =(SELECT staff_id 
FROM sale.staff
WHERE first_name ='Jane' AND last_name= 'Destrey')


--Holbrook þehrinde oturan müþterilerin sipariþ tarihlerini listeleyin

SELECT *
FROM sale.orders
WHERE customer_id IN ( SELECT customer_id
					FROM sale.customer
					WHERE city ='Holbrook' )

--Abby Parks ile ayný tarihte sipariþ veren bütün müþterileri listeleyin
SELECT A.*
FROM sale.orders A INNER JOIN (SELECT A.first_name, A.last_name, B.customer_id, B.order_id, B.order_date
								FROM sale.customer A INNER JOIN sale.orders B ON A.customer_id = B.customer_id
								WHERE A.first_name='Abby' AND A.last_name='Parks' ) B ON A.order_date = B.order_date
--buna ekstra bir tane daha ýnner joýn yapabilirdim mesela;
INNER JOIN sale.customer C ON A.customer_id = C.customer_id

--Mehmet ABinin çözümü þu þekilde;

SELECT B.first_name, B.last_name, A.order_date
FROM sale.orders A INNER JOIN sale.customer B on A.customer_id=B.customer_id
 WHERE A.order_date IN  (SELECT order_date  FROM sale.orders
						 WHERE customer_id IN 
							(SELECT customer_id 
							FROM sale.customer 
							WHERE first_name = 'Abby' and last_name= 'Parks'))


--model yýlý 2020 olan ve ücreti diðer tüm elektrikli bisikletlerden fazla olan ürünlerin listesi. Bunun için bisikletlerin fiyatlarýný pahalýdan ucuza sýralamak lazým

SELECT product_name, list_price
FROM product.product
WHERE list_price > ALL (  SELECT  list_price
							FROM   product.product A INNER JOIN product.category B ON A.category_id =B.category_id
							WHERE B.category_name ='Electric Bikes')


SELECT product_name, list_price
FROM product.product
WHERE list_price > ANY (  SELECT  list_price
							FROM   product.product A INNER JOIN product.category B ON A.category_id =B.category_id
							WHERE B.category_name ='Electric Bikes')

-- any kullanýnca herhangi bir deðeri yani küçük olanlarý da getirmiþ oldu


