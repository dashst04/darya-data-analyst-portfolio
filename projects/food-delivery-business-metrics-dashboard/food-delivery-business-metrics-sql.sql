/* Проект «Сервис доставки еды»
 * Автор: Стогниева Дарья Александровна 
 * Дата: 28.02.26
*/


-- Задача 1. Расчёт DAU
SELECT log_date,
       COUNT(DISTINCT user_id) AS DAU
FROM analytics_events
JOIN cities ON analytics_events.city_id = cities.city_id
WHERE log_date BETWEEN '2021-05-01' AND '2021-06-30'
    AND city_name = 'Саранск'
    AND event = 'order'
GROUP BY log_date
ORDER BY log_date
LIMIT 10;

-- Задача 2. Расчёт Conversion Rate
SELECT DISTINCT log_date,
    ROUND(((COUNT(DISTINCT user_id) filter (WHERE event = 'order'))/COUNT(DISTINCT user_id)::numeric),2) AS CR
FROM analytics_events
LEFT JOIN cities ON analytics_events.city_id = cities.city_id
WHERE log_date BETWEEN '2021-05-01' AND '2021-06-30'
    AND city_name = 'Саранск'
GROUP BY log_date
ORDER BY log_date
LIMIT 10;

-- Задача 3. Расчёт среднего чека
-- Рассчитываем величину комиссии с каждого заказа, отбираем заказы по дате и городу
WITH orders AS
    (SELECT *,
            revenue * commission AS commission_revenue
     FROM analytics_events
     JOIN cities ON analytics_events.city_id = cities.city_id
     WHERE revenue IS NOT NULL
         AND log_date BETWEEN '2021-05-01' AND '2021-06-30'
         AND city_name = 'Саранск')

SELECT DATE_TRUNC('month',log_date)::date as "Месяц",
    COUNT(DISTINCT order_id) AS "Количество заказов",
    ROUND(SUM(commission_revenue)::numeric,2) AS "Сумма комиссии",
    ROUND((SUM(commission_revenue)::numeric/COUNT(DISTINCT order_id)::numeric),2) AS "Средний чек"
FROM orders 
GROUP BY Месяц
ORDER BY Месяц;

-- Задача 4. Расчёт LTV ресторанов
-- Рассчитываем величину комиссии с каждого заказа, отбираем заказы по дате и городу
WITH orders AS
    (SELECT analytics_events.rest_id,
            analytics_events.city_id,
            revenue * commission AS commission_revenue
     FROM analytics_events
     JOIN cities ON analytics_events.city_id = cities.city_id
     WHERE revenue IS NOT NULL
         AND log_date BETWEEN '2021-05-01' AND '2021-06-30'
         AND city_name = 'Саранск')

SELECT orders.rest_id,
       chain AS "Название сети",
       type AS "Тип кухни",
       ROUND(SUM(commission_revenue)::numeric, 2) AS LTV
FROM orders
JOIN partners ON orders.rest_id = partners.rest_id AND orders.city_id = partners.city_id
GROUP BY 1, 2, 3
ORDER BY LTV DESC
LIMIT 3;

-- Задача 5. Расчёт LTV ресторанов - самые популярные блюда
-- Рассчитываем величину комиссии с каждого заказа, отбираем заказы по дате и городу
WITH orders AS
    (SELECT analytics_events.rest_id,
            analytics_events.city_id,
            analytics_events.object_id,
            revenue * commission AS commission_revenue
     FROM analytics_events
     JOIN cities ON analytics_events.city_id = cities.city_id
     WHERE revenue IS NOT NULL
         AND log_date BETWEEN '2021-05-01' AND '2021-06-30'
         AND city_name = 'Саранск'), 

-- Рассчитываем два ресторана с наибольшим LTV 
top_ltv_restaurants AS
    (SELECT orders.rest_id,
            chain,
            type,
            ROUND(SUM(commission_revenue)::numeric, 2) AS LTV
     FROM orders
     JOIN partners ON orders.rest_id = partners.rest_id AND orders.city_id = partners.city_id
     GROUP BY 1, 2, 3
     ORDER BY LTV DESC
     LIMIT 2)

SELECT chain AS "Название сети",
    dishes.name AS "Название блюда",
    spicy,
    fish,
    meat,
    ROUND(SUM(orders.commission_revenue)::numeric, 2) AS LTV 
FROM top_ltv_restaurants 
JOIN orders ON orders.rest_id = top_ltv_restaurants.rest_id
JOIN dishes ON orders.object_id = dishes.object_id AND top_ltv_restaurants.rest_id = dishes.rest_id
GROUP BY chain, name, spicy, fish, meat
ORDER BY LTV DESC
LIMIT 5;

-- Задача 6. Расчёт Retention Rate
-- Рассчитываем новых пользователей по дате первого посещения продукта
WITH new_users AS
    (SELECT DISTINCT first_date,
                     user_id
     FROM analytics_events
     JOIN cities ON analytics_events.city_id = cities.city_id
     WHERE first_date BETWEEN '2021-05-01' AND '2021-06-24'
         AND city_name = 'Саранск'),

-- Рассчитываем активных пользователей по дате события
active_users AS
    (SELECT DISTINCT log_date,
                     user_id
     FROM analytics_events
     JOIN cities ON analytics_events.city_id = cities.city_id
     WHERE log_date BETWEEN '2021-05-01' AND '2021-06-30'
         AND city_name = 'Саранск'),

daily_retention as (
SELECT n.user_id,
n.first_date,
log_date::date - first_date::date AS day_since_install
FROM new_users n
JOIN active_users a ON n.user_id = a.user_id
WHERE log_date >= first_date),

retention_table AS (
SELECT day_since_install,
COUNT(DISTINCT user_id) AS retained_users,
ROUND(COUNT(DISTINCT user_id)::numeric/MAX(COUNT(DISTINCT user_id)) FILTER (WHERE day_since_install = 0) OVER (),2) AS retention_rate
FROM daily_retention
WHERE day_since_install < 8 
GROUP BY day_since_install
ORDER BY day_since_install)

SELECT day_since_install,
    retained_users,
    ROUND(retention_rate::numeric,2)
FROM retention_table
ORDER BY day_since_install;

-- Задача 7. Сравнение Retention Rate по месяцам
-- Рассчитываем новых пользователей по дате первого посещения продукта
WITH new_users AS
    (SELECT DISTINCT first_date,
                     user_id
     FROM analytics_events
     JOIN cities ON analytics_events.city_id = cities.city_id
     WHERE first_date BETWEEN '2021-05-01' AND '2021-06-24'
         AND city_name = 'Саранск'),

-- Рассчитываем активных пользователей по дате события
active_users AS
    (SELECT DISTINCT log_date,
                     user_id
     FROM analytics_events
     JOIN cities ON analytics_events.city_id = cities.city_id
     WHERE log_date BETWEEN '2021-05-01' AND '2021-06-30'
         AND city_name = 'Саранск'),

-- Соединяем таблицы с новыми и активными пользователями
daily_retention AS
    (SELECT new_users.user_id,
            DATE_TRUNC('month',first_date)::date AS month,
            log_date::date - first_date::date AS day_since_install
     FROM new_users
     JOIN active_users ON new_users.user_id = active_users.user_id
     AND log_date >= first_date),

retention_table AS (
SELECT month,
day_since_install,
COUNT(DISTINCT user_id) AS retained_users,
1.0 * COUNT(DISTINCT user_id) / MAX(COUNT(DISTINCT user_id)) OVER (PARTITION BY month ORDER BY day_since_install) AS retention_rate
FROM daily_retention
WHERE day_since_install < 8 
GROUP BY month,day_since_install
ORDER BY month,day_since_install)

SELECT month AS "Месяц",
    day_since_install,
    retained_users,
    ROUND(retention_rate::numeric,2)
FROM retention_table
GROUP BY Месяц, day_since_install,retained_users,retention_rate
ORDER BY Месяц,day_since_install;