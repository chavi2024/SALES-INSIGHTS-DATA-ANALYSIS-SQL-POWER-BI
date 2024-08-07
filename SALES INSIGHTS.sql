----------------Exploratory Data Analysis---------------------

----Q1. How many distinct customers are there?
SELECT COUNT(DISTINCT markets_name) 
From markets

----Q2. What is the average sales quantity  for each market?
SELECT m.markets_name, avg(sales_qty)
FROM markets m inner join  transactions t
on m.markets_code=t.market_code
group by markets_name 

---Q3. What is the best selling product BY revenue for each zone?

select zone, product_code,total_sales 
from (
SELECT zone, product_code,total_sales, rank() over(partition by zone order by total_sales desc) as r
from (
SELECT m.zone,p.product_code, sum(sales_amount) as total_sales
from markets m  inner join transactions t
on m.markets_code = t.market_code
inner join products p
on p.product_code=t.product_code
group by m.zone,p.product_code
order by total_sales desc) a) n 
where r = 1

---Q4. who are the top 5 customers by revenue?
Select c.custmer_name, sum(sales_amount) as revenue
from customers c  inner join transactions t
on c.customer_code = t.customer_code
group by c.custmer_name
order by revenue desc 
limit 5


--Q5. what  are the top 5 products by revenue?
Select p.product_code, sum(sales_amount) as revenue
from products p  inner join transactions t
on p.product_code = t.product_code
group by p.product_code
order by revenue desc 
limit 5

---Q6. Which customer have not made a purchase in the last 6 months?
SELECT c.custmer_name,
    MAX(s.order_date) AS last_purchase_date
FROM customers c 
LEFT JOIN transactions s ON c.customer_code = s.customer_code
GROUP BY c.custmer_name
HAVING MAX(s.order_date) < DATE_SUB(NOW() , INTERVAL 6 MONTH)
   OR MAX(s.order_date) IS NULL 
   
----Q7.   What is the total sales revenue for each product?
SELECT p.PRODUCT_CODE, SUM(sales_amount) as total_revenue
from products p inner join transactions s
on p.product_code=s.product_code
group by p.product_code
order by total_revenue desc

----Q8.   What is the total sales revenue for each market?
SELECT m.markets_name, SUM(sales_amount) as total_revenue
from markets m inner join transactions s
on m.markets_code =s.market_code
group by m.markets_name
order by total_revenue desc

----Q9.What is the contribution of each product type to the total sales revenue?

with cte as (
SELECT product_type, sum(sales_amount) as total_revenue
from products p left join transactions s 
on p.product_code = s.product_code
group by p.product_type
order by total_revenue desc 
)
select product_type, total_revenue, round(total_revenue/(select sum(total_revenue) from cte ) ,2)as revenue_perc
from cte

----Q10.Which markets have the highest average sales revenue per customer?

with cte as 
(
select m.markets_name, s.customer_code, sum(sales_amount) as total
from markets m inner join transactions s 
on m.markets_code=s.market_code
group by m.markets_name,s.customer_code
order by total desc)
select markets_name, avg(total) as average_per_customer
from cte
group by markets_name
order by average_per_customer desc

---Q11. Which product has the highest contribution in total revenue ?

with cte as 
(select p.product_code, sum(sales_amount) as revenue
from products p inner join transactions s 
on p.product_code=s.product_code
group by p.product_code)
select product_code, 100*revenue/(select sum(revenue) from cte) as percentage_cont
from cte
group by product_code
order by percentage_cont desc

----Q12.Which market has the highest contribution in total revenue ?
with cte as(
SELECT m.markets_name, SUM(sales_amount) as total_revenue
from markets m inner join transactions s
on m.markets_code =s.market_code
group by m.markets_name
order by total_revenue desc)
select markets_name, total_revenue*100/(select sum(total_revenue) from cte) as percentage_cont
from cte
group by markets_name
order by percentage_cont desc

-----Q13. Who are the top 5 customers by revenue  for the market Delhi NCR?
select c.custmer_name,sum(sales_amount) as total_revenue
from customers c inner join transactions s
on c.customer_code=s.customer_code 
inner join markets m on m.markets_code=s.market_code
where m.markets_name = 'Delhi NCR'
group by c.custmer_name 
order by total_revenue desc
limit 5











   