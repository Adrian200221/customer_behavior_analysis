select * from customer limit 20
--¿Cuál es el ingreso total generado por clientes hombres vs. mujeres?
select gender, SUM(purchase_amount) as revenue
from customer
group by gender
--¿Qué clientes usaron un descuento pero aun así gastaron más que el monto promedio de compra?
select customer_id, purchase_amount 
from customer
where discount_applied = 'YES' and purchase_amount >= (select AVG(purchase_amount) from customer)
from customer 
 
--¿Cuáles son los 5 productos principales con la calificación promedio de reseñas más alta?
select item_purchased, ROUND(AVG(review_rating::numeric),2) as "Average Product Rating"
from customer
group by item_purchased
order by avg(review_rating) desc
limit 5

--Compare el gasto promedio por compra entre envío estándar y envío exprés.
select shipping_type,
ROUND(AVG(purchase_amount),2)
from customer
where shipping_type in ('Standard','Express')
group by shipping_type

--¿Los clientes suscritos gastan más? Compare el gasto promedio y el ingreso total entre suscriptores y no suscriptores.
select  subscription_status,
COUNT(customer_id) as total_customers,
ROUND(AVG(purchase_amount),2) as avg_spend,
ROUND(SUM(purchase_amount),2) as total_revenue
from customer
group by subscription_status
order by total_revenue, avg_spend desc;


--¿Qué 5 productos tienen el porcentaje más alto de compras con descuentos aplicados?

select item_purchased,
ROUND(100 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) as discount_rate
from customer
group by item_purchased
order by discount_rate desc
limit 5;

--Segmente a los clientes en: nuevos, recurrentes y 
--leales según su númerototal de compras anteriores, y muestre el conteo de cada segmento.
with customer_type as (
select customer_id, previous_purchases,
CASE 
	WHEN previous_purchases = 1 THEN 'Nuevo'
	WHEN previous_purchases BETWEEN  2 AND 10 THEN 'Recurrente'
	ELSE 'Leal'
	END AS customer_segment
from customer
)

select customer_segment, count(*) as Numero_de_Clientes
from customer_type
group by customer_segment

--¿Cuáles son los 3 productos más comprados dentro de cada categoría?
with item_counts as (
select category,
item_purchased,
COUNT(customer_id) as total_orders,
ROW_NUMBER() over(partition by category order by count(customer_id) DESC) as item_rank
from customer
group by category, item_purchased
)

select item_rank, category, item_purchased, total_orders
from item_counts
where item_rank <= 3;

--¿Los clientes que son compradores recurrentes (más de 5 compras previas) 
--también tienen probabilidad de suscribirse?
select  subscription_status,
count(customer_id) as repeat_buyers
from customer
where previous_purchases > 5
group by subscription_status

--¿Cuál es la contribución de ingresos de cada grupo de edad?
select age_group,
sum(purchase_amount) as total_revenue
from customer
group by age_group
order by total_revenue desc;
