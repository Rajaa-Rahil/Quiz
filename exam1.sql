create table members(
  customer_id varchar2(1) not null,
  join_date timestamp not null,
  primary key(customer_id)
    );


create table menu(
    product_id number not null,
    product_name varchar2(5) not null,
    price number not null,
    primary key (product_id),
    check(price>0)
    );

create table sales(
   customer_id varchar2(1) not null, 
    order_date date not null,
   product_id number,
   foreign key (customer_id) references members(customer_id),
   foreign key (product_id) references menu(product_id) 
);

select * from members;
select * from menu;
select * from sales;

truncate table sales;
truncate table members;
truncate table menu;

-- Q1: Write a query to display the total amount each customer spent at the restaurant –order by customer_id.
 
-- select * from members;

select m.customer_id, sum(mn.price) as total_price
from members m
join sales s on s.customer_id = m.customer_id
join menu mn on mn.product_id = s.product_id
group by m.customer_id
order by m.customer_id;

-- Q2: Write a query to display how many days has each customer visited the restaurant

select customer_id, count(distinct(order_date)) as count_days
from sales s
group by customer_id
order by customer_id;

/* Q3: Write a query to display each customer, and the total points there have earned - each $1
spent equates to 10 points and sushi has a 2x points multiplier - how many points would
each customer have.*/

-- select * from menu;

with t as (
            select s.customer_id, m.product_name, m.price,
                case when m.product_name = 'sushi' then m.price * 10*2
                else m.price * 10
                end as points
            from sales s 
            join menu m on m.product_id = s.product_id
            order by s.customer_id
           )

select customer_id, sum(points) total_points
from t
group by customer_id;

/* Q4: Write a query to display both the total items and amount spent for each member before
they became a member*/

with t1 as (
            select m.customer_id, m.JOIN_DATE, s.ORDER_DATE, mn.product_id, mn.price
            from members m
            join sales s on s.customer_id = m.customer_id
            join menu mn on mn.product_id = s.product_id
            where ORDER_DATE< JOIN_DATE
            order by m.customer_id
           )

select customer_id, count(PRODUCT_ID) as items, sum(price) as amount
from t1
group by customer_id
order by customer_id;

/*Q5: Create a view to display all the ‘pending user mapping’ sales – sales that were placed
before a user joined.*/

-- DROP VIEW pending_maping;
create view pending_user_maping as
     select s.customer_id, s.product_id, m.join_date, s.order_date
     from members m
     join sales s on s.customer_id = m.customer_id
     where ORDER_DATE< JOIN_DATE
     order by m.customer_id;

 select * from  pending_user_maping;      

/* Q6: Write a query to identify what was the earliest date a customer placed an order and
how many days after it did a customer join the loyalty program */

with t1 as (
             select s.customer_id, s.product_id, m.join_date, s.order_date
             from members m
             join sales s on s.customer_id = m.customer_id
             where ORDER_DATE>= JOIN_DATE
             order by m.customer_id),

    t2 as (
            select customer_id, count(distinct(order_date)) as day_numbers
            from t1
            group by customer_id
            order by customer_id)

select s.customer_id, min(s.ORDER_DATE) earliest_date, t2.day_numbers
from sales s
join t2 on t2.customer_id = s.customer_id
group by s.customer_id, t2.day_numbers
order by s.customer_id;







