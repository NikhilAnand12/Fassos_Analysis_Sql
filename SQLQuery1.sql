drop table if exists driver;
CREATE TABLE driver(driver_id integer,reg_date date); 

INSERT INTO driver(driver_id,reg_date) 
 VALUES (1,'01-01-2021'),
(2,'01-03-2021'),
(3,'01-08-2021'),
(4,'01-15-2021');


drop table if exists ingredients;
CREATE TABLE ingredients(ingredients_id integer,ingredients_name varchar(60)); 

INSERT INTO ingredients(ingredients_id ,ingredients_name) 
 VALUES (1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');

drop table if exists rolls;
CREATE TABLE rolls(roll_id integer,roll_name varchar(30)); 

INSERT INTO rolls(roll_id ,roll_name) 
 VALUES (1	,'Non Veg Roll'),
(2	,'Veg Roll');

drop table if exists rolls_recipes;
CREATE TABLE rolls_recipes(roll_id integer,ingredients varchar(24)); 

INSERT INTO rolls_recipes(roll_id ,ingredients) 
 VALUES (1,'1,2,3,4,5,6,8,10'),
(2,'4,6,7,9,11,12');

drop table if exists driver_order;
CREATE TABLE driver_order(order_id integer,driver_id integer,pickup_time datetime,distance VARCHAR(7),duration VARCHAR(10),cancellation VARCHAR(23));
INSERT INTO driver_order(order_id,driver_id,pickup_time,distance,duration,cancellation) 
 VALUES(1,1,'01-01-2021 18:15:34','20km','32 minutes',''),
(2,1,'01-01-2021 19:10:54','20km','27 minutes',''),
(3,1,'01-03-2021 00:12:37','13.4km','20 mins','NaN'),
(4,2,'01-04-2021 13:53:03','23.4','40','NaN'),
(5,3,'01-08-2021 21:10:57','10','15','NaN'),
(6,3,null,null,null,'Cancellation'),
(7,2,'01-08-2021 21:30:45','25km','25mins',null),
(8,2,'01-10-2021 00:15:02','23.4 km','15 minute',null),
(9,2,null,null,null,'Customer Cancellation'),
(10,1,'01-11-2021 18:50:20','10km','10minutes',null);


drop table if exists customer_orders;
CREATE TABLE customer_orders(order_id integer,customer_id integer,roll_id integer,not_include_items VARCHAR(4),extra_items_included VARCHAR(4),order_date datetime);
INSERT INTO customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)
values (1,101,1,'','','01-01-2021  18:05:02'),
(2,101,1,'','','01-01-2021 19:00:52'),
(3,102,1,'','','01-02-2021 23:51:23'),
(3,102,2,'','NaN','01-02-2021 23:51:23'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,2,'4','','01-04-2021 13:23:46'),
(5,104,1,null,'1','01-08-2021 21:00:29'),
(6,101,2,null,null,'01-08-2021 21:03:13'),
(7,105,2,null,'1','01-08-2021 21:20:29'),
(8,102,1,null,null,'01-09-2021 23:54:33'),
(9,103,1,'4','1,5','01-10-2021 11:22:59'),
(10,104,1,null,null,'01-11-2021 18:34:49'),
(10,104,1,'2,6','1,4','01-11-2021 18:34:49');





select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;


------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

A. Roll Metrics
B. Driver And Customer Experience
C. Ingredient Optimisation
D. Pricing and Ratings

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Q  How Many Total Orders Received and Give the Result According to items ?

select roll_id,count(roll_id) as total_order
from customer_orders
group by roll_id

--InSights-- As roll_id 1 is Non-Veg Where as roll_id 2 is Veg So Total Non-Veg Rolls ordered are 10 where as Total Veg Roll Orders were 4

------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------
------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------

--Q How Many Unique Customers were made ?

select count(distinct(customer_id)) as Total_unique_customer from customer_orders

--InSights-- Only 5 customers who ordered the roll rest of are the repeat orders

------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------
------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------

--Q How Many Successfull Order were Delivered by each Driver ?

select driver_id,count(*) as Order_Deliverd
from
(select *,case when cancellation is null then 'Deliverd'
when cancellation in('NaN','') then 'Deliverd'
else cancellation end as Status
from driver_order) as main_table
where Status = 'Deliverd'
group by driver_id

--InSights-- As Data is Not clean there is some null values as well as NaN Firstly worked on Data Cleaning and Pre Processing by using case statment where we fill the data
--   then we use the concept of subquery and get the total orders deliverd as per Each Driver

------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------
------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------

-- Q How many each type of rolls delivered ?

select n.roll_id,count(*) as Rolls_Delivered from
(select c.order_id,c.roll_id,case when cancellation is null then 'Deliverd'
when cancellation in('NaN','') then 'Deliverd'
else cancellation end as Status
from customer_orders as c join driver_order as d
on c.order_id=d.order_id) as n
where Status='Deliverd'
group by n.roll_id

------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------
------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------

-- Q For Each customer how many delivered rolls had atleast Multiple order and Single Order ?

with driver_order_new1 as( 
select order_id,driver_id,pickup_time,distance,duration,case when cancellation is null then 'Deliverd'
when cancellation in('NaN','') then 'Deliverd'
else cancellation end as Status
from driver_order )

select customer_id,case when max(rn) >= 2 then 'Multiple Order' else 'Single Order' end as Total_Orders from(
select c.customer_id,c.roll_id,row_number() over(partition by customer_id order by roll_id) as rn
from customer_orders as c inner join driver_order_new1 as d on c.order_id=d.order_id 
group by c.customer_id,c.roll_id) as b
group by customer_id

-- Insights - 

------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------
------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------
select * from customer_orders

-- Q For each customer how many delivered roles had atleast 1 change in rolls and how many had no change in rolls?

with customer_orders_new as (
select order_id,customer_id,roll_id,order_date,case when not_include_items is Null then '0' 
when not_include_items='' then '0' 
else not_include_items end as not_include_item,
case when extra_items_included is null then '0'
when extra_items_included in ('','NaN') then '0' 
else extra_items_included end as extra_item_included
from customer_orders)
select distinct(customer_id),case when not_include_item = '0' and extra_item_included='0' then 'No Change' else 'Change' end as status 
from customer_orders_new
order by status asc

-- Insights --Here we use the concept of case statment and with clause with that we clean and organised data and get the output of those customer who had change in rolls and no change in rolls

------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------
------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------

-- Q How many rolls were delivered that had both exlusion and extraes ?

with customer_orders_new as (
select order_id,customer_id,roll_id,order_date,case when not_include_items is Null then '0' 
when not_include_items='' then '0' 
else not_include_items end as not_include_item,
case when extra_items_included is null then '0'
when extra_items_included in ('','NaN') then '0' 
else extra_items_included end as extra_item_included
from customer_orders)
select distinct customer_id from customer_orders_new
where not_include_item>'0' and extra_item_included >'0'

-- Insights-- We are finding here the customer ID who add some extra ingredients and remove some ingredients.With the help of this it is easy for the outlet to calculate the amount

------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------
------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------

-- Q What was the total number of rolls were ordered for each hour of the day ?

select hour_interval,count(1) as no_of_order 
from
(select order_id,order_date,customer_id,concat(datepart(hour,order_date),'-',datepart(hour,order_date)+1) as hour_interval
from customer_orders) as n
group by hour_interval
order by no_of_order desc

-- Insights Here we use the concept of concatination and date function to get how many orders are recived at what time and get the maximum order time

------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------
------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------

--Q What was the total number of the orders recived for each day of the week ?
select Day_name,count(1) as no_of_order from
(select order_id,datename(dw,order_date) as Day_name
from customer_orders) as n
group by day_name

--Insights - On which day no of order are recieved higher as according to above query on weekend their is more orders
------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------
------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------

-- Q What was the average time in minutes it took for each driver who arrive at the fassos to pickup the order ?

select driver_id,avg(diff) as average_time from
(select a.order_id,b.driver_id,DATEDIFF(minute,a.order_date,b.pickup_time) as diff,ROW_NUMBER() over(partition by a.order_id order by a.order_id)as rn
from customer_orders as a join driver_order as b on a.order_id=b.order_id
where b.pickup_time is not null) as n
where rn = 1
group by driver_id
order by average_time desc

-- Insights -- From above query we get the average time taken by the driver for picking up the order. Driver id(2) took the highest time for picking up the order 

------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------
select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes
--------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------

-- Q Is there any relationship between the number of rolls and how long the order takes to prepare


select a.order_id,count(*) as no_of_order ,sum(diff)/COUNT(roll_id) as Time_taken_per_order from
(select a.order_id,a.roll_id,b.driver_id,DATEDIFF(minute,a.order_date,b.pickup_time) as diff,ROW_NUMBER() over(partition by a.order_id order by a.order_id)as rn
from customer_orders as a join driver_order as b on a.order_id=b.order_id
where b.pickup_time is not null) as a 
group by a.order_id

-- Insights - The more the rolls are order at same time the more time taken by the restaurant as the ideal time for preparing the single roll is 10 minute

------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------
------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------

-- Q What was the average distance travelled for each customer by the driver ?

select customer_id,round(avg(v),1) as for_each_customer from
(select a.customer_id,a.order_id,b.driver_id,a.roll_id,cast(trim(replace(lower(b.distance),'km','')) as decimal(4,2)) as v,DATEDIFF(minute,a.order_date,b.pickup_time) as diff,b.distance
from customer_orders as a join driver_order as b on a.order_id=b.order_id
where b.pickup_time is not null) as y
group by customer_id

------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------
------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$-----------------------------------------------------------------------

-- Q What was the differnce between the longest and shortest delivery time for all orders?


select (max(l_duration)-min(l_duration)) as Differnce from(
select cast(case when duration like '%min%' then left(duration,CHARINDEX('m',duration)-1) else duration end as integer) as l_duration from driver_order
where duration is not null) as n

-- Insights - The maximum time taken to deliver the order is 30 min by the driver

------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------
------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$-----------------------------------------------------------------------

-- Q What was the average speed for each driver for each delivery and do you notice any trend for these values ?
select driver_id,order_id,(1.00*sum(v)/sum(l_duration)) as avg_Speed from
(select driver_id,order_id,cast(trim(replace(lower(distance),'km','')) as decimal(4,2)) as v,cast(case when duration like '%min%' then left(duration,CHARINDEX('m',duration)-1) else duration end as integer) as l_duration 
from driver_order
where duration is not null) as z
group by driver_id,order_id
order by driver_id

------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------
------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$-----------------------------------------------------------------------

-- Q What is the succesfully delivery percentage for each driver ?
select * from driver_order

select driver_id,(1.00*sum(succesfull_order)/count(*)) as Sucessfull_delivery_percentage from
(select *,case when cancellation like '%Cancel%' then 0 else 1 end as succesfull_order  
from driver_order) as a
group by driver_id

-- Insights - Through this query we can get the driverID whose cancellation percentage is low and if we can reward the Driver to motivate him to stay in the company

------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$------------------------------------------------------------------------------------
------------------------------------------$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$----------------------------------------------------------------------








