--Top 10 Sellers by Revenue

with seller_revenue as(
select oi.seller_id, sum(oi.price + oi.freight_value) as revenue
from clean_orders c
join order_items oi on  c.order_id = oi.order_id
group by oi.seller_id
)
select seller_id, revenue, 
	round(
		(revenue / sum(revenue) over ())::NUMERIC * 100 , 2)
		 as revenue_pct
from seller_revenue
order by revenue_pct desc
limit 10;


--Top Sellers by Number of Orders
select seller_id, count(distinct(order_id)) as total_orders
from order_items
group by seller_id
order by total_orders desc
limit 10;


-- Which payment methods are customers using the most?

select 
	payment_type,
	COUNT(*) as total_payments,
	ROUND(
	(COUNT(*)::numeric / SUM(COUNT(*)) OVER()) * 100,2
	) as payment_pct
from order_payments
group by payment_type
order by total_payments desc;


--How do customers use payment installments?

select 
	payment_installments,
	COUNT(*) as total_payments,
	ROUND(AVG(payment_value)::numeric,2) as avg_payment_value
from order_payments 
where payment_installments > 0
group by payment_installments 
order by avg_payment_value;


--What is the average transaction/payment size?

select 
	ROUND(avg(payment_value)::numeric,2) as avg_payment_value
from order_payments;


