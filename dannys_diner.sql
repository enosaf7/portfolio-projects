CREATE DATABASE dannys_diner;
USE dannys_diner;

CREATE TABLE sales (
  customer_id CHAR(1),
  order_date DATE,
  product_id INT
);

INSERT INTO sales (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', 1),
  ('A', '2021-01-01', 2),
  ('A', '2021-01-07', 2),
  ('A', '2021-01-10', 3),
  ('A', '2021-01-11', 3),
  ('A', '2021-01-11', 3),
  ('B', '2021-01-01', 2),
  ('B', '2021-01-02', 2),
  ('B', '2021-01-04', 1),
  ('B', '2021-01-11', 1),
  ('B', '2021-01-16', 3),
  ('B', '2021-02-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-07', 3);

CREATE TABLE menu (
  product_id INT,
  product_name VARCHAR(5),
  price INT
);

INSERT INTO menu (product_id, product_name, price)
VALUES
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12);

CREATE TABLE members (
  customer_id CHAR(1),
  join_date DATE
);

INSERT INTO members (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  
  
  
  
  /* --------------------
   Case Study Questions
   --------------------*/
   
-- 1. What is the total amount each customer spent at the restaurant?
select customer_id, sum(price) as Total_Amount_Spent
from menu as m
join sales as s
on m.product_id=s.product_id
group by s.customer_id;


-- 2. How many days has each customer visited the restaurant?
select customer_id, count(order_date) as "No. Of times visited"
from sales
group by customer_id;


-- 3. What was the first item from the menu purchased by each customer?
with cte as 
(
select s.customer_id, m.product_name,
ROW_NUMBER () over (partition by s.customer_id order by s.order_date) as rn
from sales as s
join menu as m
on s.product_id = m.product_id
)
select customer_id, product_name
from cte
where rn = 1;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select m.product_name, count(m.product_id) as No_of_purchases
from sales as s
join menu as m
on s.product_id = m.product_id
group by m.product_name
order by No_of_purchases desc
limit 1;





-- 5. Which item was the most popular for each customer?
with cte as
(
select s.customer_id, m.product_name, count(*),
rank() over (partition by s.customer_id order by count(*) DESC) as rn
from sales as s
join menu as m
on s.product_id = m. product_id
group by s.customer_id,m.product_name
)
select customer_id, product_name
from cte where rn = 1;


-- 6. Which item was purchased first by the customer after they became a member?
with cte as 
(
select s.customer_id, mm.join_date, m.product_name, count(*),
rank() over (partition by s.customer_id order by count(*) desc) as rn
from sales as s
join members as mm
on s.customer_id = mm.customer_id
join menu as m
on s.product_id = m.product_id
group by s.customer_id, m.product_name,mm.join_date
)
select customer_id,product_name
from cte
where rn=1
limit 2;


-- 7. Which item was purchased just before the customer became a member?
with cte as
(
select s.customer_id,s.order_date,m.product_id,mm.join_date,m.product_name
from sales as s
join menu as m
on s.product_id = m.product_id
join members as mm
on s.customer_id = mm.customer_id
)
select *
from cte
where order_date <join_date
limit 2;


-- 8. What is the total items and amount spent for each member before they became a member?
select customer_id, group_concat(product_name order by product_name) as products, total_spent
from(select mm.customer_id, m.product_name,m.price, sum(m.price) over (partition by mm.customer_id) as total_spent
from sales as s 
join menu as m on s.product_id = m.product_id
join members as mm on s.customer_id = mm.customer_id
where mm.join_date > s.order_date)
as subquery group by customer_id, total_spent
order by customer_id;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with cte as (
select s.customer_id, m.product_name, m.price,
	case
		when m.product_name = 'sushi' then m.price*10*2
		else m.price*10
	end as Points
from sales as s
join menu as m on s.product_id = m.product_id
)
select customer_id, sum(points)
from cte
group by customer_id;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - 
-- how many points do customer A and B have at the end of January?
with cte as
(
select s.customer_id, m.product_name, m.price, s.order_date, mm.join_date,
CASE 
	WHEN s.order_date between mm.join_date and date_add(mm.join_date, interval 7 day) then m.price*10*2
    WHEN m.product_name = 'sushi' then m.price*10*2
    ELSE m.price*10
END as points
from menu as m
join sales as s on m.product_id = s.product_id
join members as mm on s.customer_id = mm.customer_id
where s.order_date < '2021-02-01'
)
select customer_id, SUM(points) as total_points
from cte
group by customer_id;