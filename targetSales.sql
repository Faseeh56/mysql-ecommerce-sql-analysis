-- select queries
select * from customers;
select * from orders;
select * from payments;
select customer_id,customer_state from customers;

-- where clause
select * from customers where customer_state = 'MG';
select * from orders where order_status = 'canceled'; 

-- And operator
select * from payments where
payment_type = "UPI" and payment_value >= 3000;

-- OR operator
select * from customers where
customer_state = "SP" or customer_city = "sao paulo";

-- Not operator
select * from customers where
not (customer_state = "SP" or customer_city = "sao paulo");

-- Between operator
select * from payments where
payment_value between 150  and 154;

-- in operator
select * from customers where
customer_state in ("SC","PR","SP","MG");

-- not in operator
select * from customers where
customer_state not in ("SC","PR","SP","MG");

-- like operator (select specifc character in string)
select * from customers where customer_city like "%rd";
select * from customers where customer_city like "or%";
select * from customers where customer_city like "%de%";

-- order by (Asending and Desending)
select * from payments order by payment_value;
select * from payments order by payment_value desc;
select * from payments order by payment_value, payment_type;
select * from payments order by payment_value, payment_type desc;
select * from payments where
payment_installments = 1 
order by payment_value;
select * from payments where
payment_installments = 1 
order by payment_value desc;  

-- limit
select * from products limit 5;  -- 1st 5 rows fetched 
select * from products limit 2,3; -- 1st 2 rows left and next 3 fetched

-- function

-- round
select payment_value,round(payment_value,1) from payments;
select payment_value,ceil(payment_value) from payments;
select payment_value,floor(payment_value) from payments;

-- aggregate  
select sum(payment_value), round(sum(payment_value),2) as total_revenue from payments;
select max(payment_value),min(payment_value),round(avg(payment_value),4) from payments;
select count(customer_id),count(customer_city) from customers; -- count to total number of rows
select count(distinct customer_city) from customers; -- counts the unique atributes of a coulmn 

-- strings
select seller_city, length(seller_city), length(trim(seller_city)) from sellers; -- number of characters in seller city
select upper(seller_city), lower(seller_city) from sellers;
select seller_city, replace(seller_city,'a','i') from sellers;
select concat(seller_city," - ",seller_state) as City_State from sellers;
select *, concat(seller_city," - ",seller_state) as City_State from sellers;

-- date time
select order_delivered_customer_date,
day(order_delivered_customer_date),
month(order_delivered_customer_date),
monthname(order_delivered_customer_date),
year(order_delivered_customer_date),
dayname(order_delivered_customer_date)
from orders;
select datediff(order_estimated_delivery_date, order_delivered_customer_date) from orders;

-- null check
select * from orders where order_approved_at is null; 

-- group by
select order_status, count(order_status) as order_count 
from orders
group by order_status 
order by order_count desc;
select customer_state, count(customer_state) as state_count 
from customers
group by customer_state 
order by state_count;
select payment_type, round(avg(payment_value),2) as avg_payment
from payments 
group by payment_type 
order by avg_payment;
select payment_type, round(avg(payment_value),2) as avg_payment
from payments 
where payment_installments = 1
group by payment_type 
order by avg_payment;
select payment_type, round(avg(payment_value),2) as avg_payment
from payments 
group by payment_type 
having avg(payment_value) >= 100;

-- joins
select customers.customer_id,orders.order_status 
from customers join orders
on customers.customer_id = orders.customer_id;

select customers.customer_id,orders.order_status 
from customers join orders
on customers.customer_id = orders.customer_id
where order_status = "canceled";

select year(orders.order_purchase_timestamp) as years,round(sum(payments.payment_value),2) as sum_of_payments_in_year
from orders join payments
on orders.order_id = payments.order_id
group by years order by years;

select (products.product_category) as category,round(sum(payments.payment_value),2) as sales
from products join order_items 
on products.product_id = order_items.product_id
join payments
on payments.order_id = order_items.order_id
group by category order by sales desc limit 5;

-- subqueries

-- tree
select category from
(select (products.product_category) as category,sum(payments.payment_value) as sales
from products join order_items 
on products.product_id = order_items.product_id
join payments
on payments.order_id = order_items.order_id
group by category order by sales desc limit 5) as tree;

-- CTA common table expression
with a as (select (products.product_category) as category,sum(payments.payment_value) as sales
from products join order_items 
on products.product_id = order_items.product_id
join payments
on payments.order_id = order_items.order_id
group by category order by sales desc limit 5)

select category from a;

-- case statement  

with a as (select (products.product_category) as category,sum(payments.payment_value) as sales
from products join order_items 
on products.product_id = order_items.product_id
join payments
on payments.order_id = order_items.order_id
group by category order by sales desc)
select *, case
when sales <= 5000 then "low"
when sales >= 100000 then "high" 
else "medium"
end as sales_type
from a;

-- window function

select order_date,sales,
sum(sales) over(order by order_date) from
(select date(orders.order_purchase_timestamp) order_date, sum(payments.payment_value) sales
from orders join payments 
on orders.order_id = payments.order_id 
group by order_date) as a;


with a as (select (products.product_category) as category,sum(payments.payment_value) as sales
from products join order_items 
on products.product_id = order_items.product_id
join payments
on payments.order_id = order_items.order_id
group by category)
select category, sales, rank() over(order by sales desc)
from a;

with a as (select (products.product_category) as category,sum(payments.payment_value) as sales
from products join order_items 
on products.product_id = order_items.product_id
join payments
on payments.order_id = order_items.order_id
group by category),
b as (select category, sales, rank() over(order by sales desc) as rk
from a)
select category, sales from b where rk <= 3;

-- view

create view category_sales_view as 
select (products.product_category) as category,sum(payments.payment_value) as sales
from products join order_items 
on products.product_id = order_items.product_id
join payments
on payments.order_id = order_items.order_id
group by category;