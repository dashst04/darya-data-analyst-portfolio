/* Проект: Анализ продуктовых метрик и юнит-экономики маркетплейса
 *
 * Автор:Стогниева Дарья Александровна
 * Дата:27.07.2026
*/

-- Первичный анализ и сбор данных
-- 1. Сбор данных о пользователях
SELECT user_id,
    registration_date,
    user_params->>'age' AS age,
    user_params->>'gender' AS gender,
    user_params->>'region' AS region,
    user_params->>'acq_channel' AS acq_channel,
    user_params->>'buyer_segment' AS buyer_segment,
    (DATE_TRUNC('week', registration_date::timestamp))::date AS cohort_week,
    (DATE_TRUNC('month', registration_date::timestamp))::date AS cohort_month
FROM pa_graduate.Users
WHERE registration_date >= DATE '2024-01-01' AND registration_date < DATE '2025-01-01'
ORDER BY registration_date
LIMIT 100;

-- user_id	registration_date	 age	gender	region				acq_channel	 buyer_segment	cohort_week	 cohort_month
-- 25		2024-01-01 00:07:00	 22		M		Другие регионы		Google Ads	 rare			2024-01-01	 2024-01-01
-- 55		2024-01-01 00:26:00	 46		F		Другие регионы		Google Ads	 medium			2024-01-01	 2024-01-01
-- 52		2024-01-01 00:36:00	 36		M		Московская область	Google Ads	 medium			2024-01-01	 2024-01-01
-- 62		2024-01-01 00:40:00	 56		M		Другие регионы		Google Ads	 rare			2024-01-01	 2024-01-01
-- ...

-- 2. Сбор данных о событиях
SELECT e.event_id,
    e.user_id,
    e."timestamp" AS event_date,
    e.event_type,
    e.event_params->>'os' AS os,
    e.event_params->>'device' AS device,
    p.product_name,
    (DATE_TRUNC('week', e."timestamp"::timestamp))::date AS event_week,
    (DATE_TRUNC('month', e."timestamp"::timestamp))::date AS event_month
FROM pa_graduate.Events AS e
LEFT JOIN pa_graduate.Product_dict AS p ON e.product_id=p.product_id
WHERE e."timestamp" >= DATE '2024-01-01' AND e."timestamp" < DATE '2025-01-01'
ORDER BY e.timestamp
LIMIT 100;

-- event_id	user_id	 event_date	 			event_type	 	os	 device	 product_name		event_week	event_month
-- 6945		100		 2024-01-01 08:35:52	user_logout		iOS	 mobile						2024-01-01	2024-01-01
-- 6935		100	 	 2024-01-01 08:36:53	product_view	iOS	 mobile	 Туфли на каблуке	2024-01-01	2024-01-01
-- 6958		100	 	 2024-01-01 08:37:24	checkout_start	iOS	 mobile						2024-01-01	2024-01-01
-- 6953		100	 	 2024-01-01 08:37:47	filter_apply	iOS	 mobile						2024-01-01	2024-01-01
-- 6937		100		 2024-01-01 08:38:30	filter_apply	iOS	 mobile						2024-01-01	2024-01-01
-- ...

-- 3. Сбор данных о заказах
SELECT o.order_id,
    o.user_id,
    o.order_date,
    p.product_name,
    o.quantity,
    o.unit_price,
    o.total_price,
    p.category_name,
    (DATE_TRUNC('week', o.order_date::timestamp))::date AS order_week,
    (DATE_TRUNC('month', o.order_date::timestamp))::date AS order_month
FROM pa_graduate.Orders AS o
LEFT JOIN pa_graduate.Product_dict AS p ON o.product_id=p.product_id
WHERE o.order_date >= DATE '2024-01-01' AND o.order_date < DATE '2025-01-01'
ORDER BY o.order_date
LIMIT 100;

-- order_id	user_id	order_date			 product_name			quantity	unit_price	total_price	category_name			order_week	order_month
-- 117		100		2024-01-01 08:03:45	 Стеллаж для книг		2			15689.9		31379.7		Мебель для дома			2024-01-01	2024-01-01
-- 77		45		2024-01-02 01:32:02	 Помада матовая			2			7632.66		15265.3		Косметика и парфюмерия	2024-01-01	2024-01-01
-- 78		48		2024-01-02 09:28:48	 Утюг с паром			1			17791.3		17791.3		Бытовая техника			2024-01-01	2024-01-01
-- 186		159		2024-01-03 01:27:35	 Baseus зарядка			3			11751.9		35255.6		Аксессуары для гаджетов	2024-01-01	2024-01-01
-- 148		101		2024-01-03 04:35:08	 Толстовка с капюшоном	3			5150.47		15451.4		Одежда для спорта		2024-01-01	2024-01-01
-- ...