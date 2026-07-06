--Top 10 States by Number of Customers

select 
	customer_state , 
	count(distinct c.customer_id) as total_customers
from customers c
join clean_orders co on c.customer_id = co.customer_id
group by c.customer_state
order by total_customers desc
limit 10;




--Top 10 Cities by Number of Customers

select 
	customer_city , 
	count(distinct c.customer_id) as total_customers
from customers c
join clean_orders co on c.customer_id = co.customer_id
group by c.customer_city
order by total_customers desc
limit 10;


-- Which customers generated the highest lifetime revenue?(CLV)

select c.customer_unique_id, SUM(co.total_payment) as lifetime_value
from customers c 
join clean_orders co on c.customer_id = co.customer_id
group by c.customer_unique_id 
order by lifetime_value desc

-- RFM Customer Segmentation
with rfm_base as (
	select 
		c.customer_unique_id,
		MAX(co.order_purchase_timestamp::timestamp) as last_purchase_date,
		COUNT(distinct co.order_id) as frequency,
		ROUND(
			SUM(co.total_payment)::numeric,2
		) as monetary
	from customers c
	join clean_orders co on c.customer_id = co.customer_id
	group by c.customer_unique_id
),
rfm_values as(
	select 
		customer_unique_id,
		extract(
		day from(
			(select MAX(order_purchase_timestamp::timestamp) 
			from clean_orders)
			-
			last_purchase_date
		)
		) as recency,
		frequency,
		monetary
		from rfm_base		
),
rfm_score as (
	select
		customer_unique_id,
		recency,
		frequency,
		monetary,
		ntile(5) OVER(
			order by recency DESC) as r_score,
		ntile(5) over(
			order by frequency) as f_score,
		ntile(5) over(
			order by monetary) as m_score
	from rfm_values
)
select 
	customer_unique_id,
	recency,
	frequency,
	monetary,
	r_score,
	f_score,
	m_score,
	case
		when r_score >=4
			and f_score >=4
			and m_score >=4 
		then 'Champion Customer'
		when r_score >=2 
			and f_score >=4
			and m_score >=4 
		then 'Loyal Customer'
		when r_score>= 4
			and f = 1
			then 'New Customer'
		when r_score = 1
			and f_score >=2
		then 'Lost Customer'
		when r_score <=2
			and f_score >= 2
		then 'At Risk Customer'
		else 'Regular Customer'
	end as customer_segment
from rfm_score;


--Cohort Retention Analysis
--Of customers who joined in a month, how many returned in later months?

with customer_orders as (
	select 
		c.customer_unique_id,
		DATE_TRUNC(
			'month',
			co.order_purchase_timestamp::timestamp) as order_month
from customers c 
join clean_orders co on c.customer_id = co.customer_id
),
cohort as( 
	select 
		customer_unique_id,
		MIN(order_month) as cohort_month
		from customer_orders 
		group by customer_unique_id 
),
cohort_data as (
	select
	co.customer_unique_id,
	c.cohort_month,
	co.order_month,
	(
		extract(year from co.order_month)
		-
		extract(year from c.cohort_month)
		)*12
		+
		(extract(month from co.order_month)
		-
		extract(month from c.cohort_month)) as month_number
	from customer_orders co
	join cohort c on co.customer_unique_id = c.customer_unique_id 
)
select 	
	cohort_month,
	month_number,
	count(distinct customer_unique_id) as customers
from cohort_data 
group by cohort_month, month_number 
order by cohort_month, month_number ;
