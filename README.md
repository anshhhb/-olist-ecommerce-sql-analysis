#olist-ecommerce-sql-analysis
SQL analysis of 98,205 Brazilian e-commerce orders using PostgreSQL

# Olist E-Commerce SQL Analysis

## What is this project?
I wanted to work on a real-world dataset to sharpen my SQL skills, 
so I picked Olist — Brazil's largest e-commerce marketplace. The 
dataset has 98,205 orders spread across 9 tables, covering everything 
from payments to delivery times to customer reviews.

All analysis was done in PostgreSQL. No shortcuts — just raw SQL.

## What I found
- Delivery experience directly impacts ratings. Orders delivered 7+ 
  days late averaged just 1.70 stars, compared to 4.29 stars for 
  on-time deliveries. That's a massive drop for something that's 
  entirely fixable.

- Revenue peaked in November 2017. Growth was strong through 2017–2018 before the dataset ends.

- The top 10 sellers drive 14% of total revenue, showing how 
  concentrated the marketplace is at the top.

- Using RFM scoring, 16% of customers qualify as Champions — 
  high value, recent, and frequent buyers.

## What I built
- A clean base view filtering out cancelled orders and the dataset's 
  abrupt Oct 2018 cutoff — every analysis runs on top of this
- Month-on-month revenue trend using LAG() window function
- RFM customer segmentation across 3 CTEs using NTILE(5)
- Cohort retention analysis tracking repeat purchases month by month
- Delivery delay buckets mapped against average review scores
- Seller performance ranking with revenue share percentages
- Payment method breakdown including Brazil's instalment culture

## Skills used
CTEs, Window Functions (LAG, NTILE, RANK), Multi-table JOINs, 
Date/Time functions, Views, Data Cleaning in SQL

## Tools
PostgreSQL · DBeaver

## Dataset
Kaggle — Brazilian E-Commerce Public Dataset by Olist
