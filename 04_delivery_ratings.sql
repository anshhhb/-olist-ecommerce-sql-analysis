-- Average Delivery Time


select ROUND(AVG(
			EXTRACT(day from
		(co.order_delivered_customer_date::timestamp 
		- co.order_purchase_timestamp::timestamp))),2)  as avg_delivery_days
from clean_orders co
where nullif(co.order_delivered_customer_date, '') is not null ;



-- Which customer states have the fastest and slowest delivery times?

select
	c.customer_state,
	ROUND(AVG(extract (day from 
	(co.order_delivered_customer_date::timestamp 
	- co.order_purchase_timestamp::timestamp ))),2) as avg_delivery_time
from clean_orders co
join customers c on co.customer_id = c.customer_id
where nullif(co.order_delivered_customer_date, '') is not null
group by c.customer_state
order by avg_delivery_time asc;



-- What percentage of orders were delivered later than estimated date?

	
with delivery as (select count(order_id) as total_orders,
		COUNT(case when(
		nullif(order_delivered_customer_date,'')::timestamp
		> nullif(order_estimated_delivery_date,'')::timestamp
		)
		then order_id
		end
		) as delayed_orders
from clean_orders)
select total_orders,
		delayed_orders,
		ROUND((delayed_orders::numeric / total_orders)*100,2) as delayed_pct
from delivery;




--Estimated vs Actual Delivery Analysis



with delivery_status as (
	select order_id,
		case  
				when nullif(order_delivered_customer_date,'')::timestamp
						> nullif(order_estimated_delivery_date,'')::timestamp then 'Late Delivery'
				when
				nullif(order_delivered_customer_date,'')::timestamp
				<nullif(order_estimated_delivery_date,'')::timestamp then 'Early Delivery'
				else 'On Time'
				end as delivery_status
	from clean_orders
	)
select 
	delivery_status,
	count(order_id) as total_orders
from delivery_status
group by delivery_status
order by total_orders desc;
	



--Average Rating
select round(avg(t.review_score ),2) as avg_rating
from order_reviews t;




--Rating Distribution

select review_score, 
		count(review_score) as total_reviews,
		ROUND(count(review_score)::NUMERIC/SUM(count(review_score)) over ()*100,2)
from order_reviews
group by review_score
order by review_score desc;



-- Which product categories have the highest and lowest customer satisfaction?

select  pe.category_en,
		COUNT(r.review_score) as total_reviews,
		ROUND(AVG(r.review_score),2) as avg_rating
from order_reviews r
join order_items oi on r.order_id = oi.order_id 
join products_en pe on oi.product_id = pe.product_id
group by pe.category_en
having COUNT(r.review_score) >= 100
order by avg_rating desc;



--Delivery Delay vs Review Score

with delivery_reviews as(
select co.order_id,
	case 
		when nullif(co.order_delivered_customer_date,'')::timestamp
		<= nullif(co.order_estimated_delivery_date,'')::timestamp
		then 'On-time'
		when EXTRACT(
		day from( 
		nullif(co.order_delivered_customer_date,'')::timestamp
		- 
		nullif(co.order_estimated_delivery_date,'')::timestamp))
		<= 3
		then '1-3 Days Late'
		when extract(
		day from(
		nullif(co.order_delivered_customer_date,'')::timestamp
		-
		nullif(co.order_estimated_delivery_date,'')::timestamp)) <= 7
		then '4-7 Days Late'
		else '7+ Days Late'
	end as delivery_status,
	t.review_score
from clean_orders co
join order_reviews t
on co.order_id = t.order_id
where nullif(co.order_delivered_customer_date, '') is not null 
)
 select 
 	delivery_status,
 	COUNT(*) as total_orders,
 	ROUND(AVG(review_score),2) as avg_rating
 from delivery_reviews
group by delivery_status
order by avg_rating DESC;
