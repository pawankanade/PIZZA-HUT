1) Create table for 'pizzas'
create table pizzas (
	pizza_id varchar(50) not null,
	pizza_type_id varchar(50) not null, 
	size varchar(50) not null,
	price numeric not null
	);

2) Create table for 'pizza_types'
create table pizza_types (
	pizza_type_id text not null,
	name text not null,
	category text not null,
	ingredients text not null
	);

3) Create table for 'orders'
create table orders (
    order_id SERIAL primary key not null,
    order_date DATE not null,
    order_time TIME not null
    );

4) Create table for 'order_details'
create table order_details (
	order_details_id int primary key not null,
	order_id int not null, 
	pizza_id text not null, 
	quantity int not null
	);

COPY pizzas( pizza_id,pizza_type_id, size, price)
from 'D:\pavan\SQL Project\PizzaHut\pizzas.csv'
delimiter ',' csv header;

1) Retrieve the total number of orders placed.

  	select count(*) as total_orders from orders;

2) Calculate the total revenue generated from pizza sales.

	select
		SUM(od.quantity * p.price) AS total_revenue
	from pizzas p 
	join order_details od
	on p.pizza_id = od.pizza_id;

3) Identify the highest-priced pizza. 
    select pt.name as highest_priced_pizza
	from pizza_types pt
	join pizzas p on pt.pizza_type_id = p.pizza_type_id
	order by p.price desc
	limit 1;
    
	
3) Identify the most common pizza size ordered.
	select pizza_size as most_common_pizza_size  
	from (
		  select p.size as pizza_size,
		 	count(p.size) as total_count
		  from order_details od
		  join pizzas p on od.pizza_id = p.pizza_id
		  group by p.size
		  order by total_count desc
		limit 1
		 )
	limit 1;

4) List the top 5 most ordered pizza types along with their quantities.

	select pt.name as pizza_type,
      	   sum(quantity) as total_quantity
	from order_details od
	join pizzas p on od.pizza_id = p.pizza_id
	join pizza_types pt on p.pizza_type_id =  pt.pizza_type_id
	group by pt.name
	order by total_quantity desc
	limit 5;


5) Join the necessary tables to find the total quantity of each pizza category ordered.

	select 
    		pt.category as category,
    		sum(quantity) as total_order_quantity
	from order_details od
	join pizzas p on od.pizza_id = p.pizza_id
	join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
	group by pt.category
	order by total_order_quantity desc;
	
6) Determine the distribution of orders by hour of the day.

	select 
    		extract(hour from order_time) as hour, 
    		count(order_id) AS orders_count from orders
	group by extract(hour from order_time)
	order by hour;


7) Join relevant tables to find the category-wise distribution of pizzas ordered.

	select 
   		pt.category as category, 
    		sum(od.quantity) as total_quantity_ordered
	from order_details od
	join pizzas p on od.pizza_id = p.pizza_id
	join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
	group by pt.category
	
	
8) Group the orders by date and calculate the average number of pizzas ordered per day.

  	select 
    		Round(avg(sum_orders_per_day)) as average_orders_per_day
  	from(
      	     select o.order_date as day, sum(od.quantity) as sum_orders_per_day
	     from orders o
	     join order_details od on o.order_id = od.order_id
	     group by o.order_date
      	    )

    
9) Determine the top 3 most ordered pizza types based on revenue.

  	select 
    		pt.name as pizza_type, 
    		sum(od.quantity * p.price) as total_revenue
	from order_details od
	join pizzas p on od.pizza_id = p.pizza_id
	join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
	group by pt.name
	order by total_revenue desc
	limit 3;


10) Calculate the percentage contribution of each pizza type/ category to total revenue.

	select 
		pt.category as pizza_type,
		round(sum(od.quantity * p.price)/(
						  select 
						       sum(od.quantity * p.price) 
						  from order_details od
						  join pizzas p on od.pizza_id = p.pizza_id
						 )*100,2) as percentage_of_revenue
	from order_details od
	join pizzas p on od.pizza_id = p.pizza_id
	join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
	group by pt.category
	 
11) Analyze the cumulative revenue generated over time.

	select
		order_date,
		sum(revenue) over(order by order_date) as cumulative_revenue
	from (
		select 
			o.order_date as order_date,
			sum(p.price * od.quantity) as revenue
		from pizzas p
		join order_details od on p.pizza_id = od.pizza_id
		join orders o on od.order_id = o.order_id
		group by o.order_date
	      )
	order by order_date;


12) Determine the top 3 most ordered pizza types based on revenue for each pizza category.

		
	select category,name,revenue,position
	from (
		select 
			pt.category as category, pt.name as name, 
			sum(od.quantity * p.price) as revenue,
			rank() over (partition by pt.category order by sum(od.quantity * p.price) desc) as position
		from order_details od
		join pizzas p on od.pizza_id = p.pizza_id
		join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
		group by pt.category, pt.name
		order by category, revenue desc 
		)
	where position in (1,2,3);

