/* Проект «Секреты Тёмнолесья»
 * Цель проекта: изучить влияние характеристик игроков и их игровых персонажей 
 * на покупку внутриигровой валюты «райские лепестки», а также оценить 
 * активность игроков при совершении внутриигровых покупок
 * 
 * Автор: Стогниева Дарья Александровна 
 * Дата: 30.11.25
*/

-- Часть 1. Исследовательский анализ данных
-- Задача 1. Исследование доли платящих игроков

-- 1.1. Доля платящих пользователей по всем данным:
SELECT
	COUNT(id) AS total_players,
	SUM(payer) AS paying_players,
	ROUND(AVG(payer),2) AS paying_players_share
FROM fantasy.users;

-- total_players|paying_players|paying_players_share|
-- -------------+--------------+--------------------+
--         22214|          3929|                0.18|

-- 1.2. Доля платящих пользователей в разрезе расы персонажа:
SELECT r.race,
	SUM(u.payer) AS total_paying_users,
	COUNT(DISTINCT u.id) AS total_users,
	ROUND(AVG(u.payer),2) AS race_paying_users_share
FROM fantasy.race AS r 
LEFT JOIN fantasy.users AS u ON r.race_id = u.race_id 
GROUP BY r.race;

-- race    |total_paying_users|total_users|race_paying_users_share|
-- --------+------------------+-----------+-----------------------+
-- Angel   |               229|       1327|                   0.17|
-- Demon   |               238|       1229|                   0.19|
-- Elf     |               427|       2501|                   0.17|
-- Hobbit  |               659|       3648|                   0.18|
-- Human   |              1114|       6328|                   0.18|
-- Northman|               626|       3562|                   0.18|
-- Orc     |               636|       3619|                   0.18|

-- Задача 2. Исследование внутриигровых покупок
-- 2.1. Статистические показатели по полю amount:
SELECT COUNT(DISTINCT transaction_id) AS count_purchase,
	SUM(amount) AS total_cost,
	MIN(amount) AS min_cost,
	MAX(amount) AS max_cost,
	AVG(amount) AS avg_cost,
	PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY amount) AS median,
	STDDEV(amount) AS stand_dev
FROM fantasy.events;

-- count_purchase|total_cost|min_cost|max_cost|avg_cost         |median|stand_dev        |
-- --------------+----------+--------+--------+-----------------+------+-----------------+
--        1307678| 686615040|     0.0|486615.1|525.6919663589833| 74.86|2517.345444427788|


-- 2.2: Аномальные нулевые покупки:
SELECT COUNT(transaction_id) AS total_purchases,
	COUNT(CASE WHEN amount = 0 THEN transaction_id END) AS total_zero_purchases,
	COUNT(CASE WHEN amount = 0 THEN transaction_id END)::FLOAT / COUNT(transaction_id) AS zero_purchases_share
FROM fantasy.events;

-- total_purchases|total_zero_purchases|zero_purchases_share|
-- ---------------+--------------------+--------------------+
--         1307678|                 907|  0.0006935958240484|

-- 2.3: Популярные эпические предметы:
WITH
item_statistics AS (
    SELECT item_code,
        COUNT(transaction_id) AS absolute_sales,
        COUNT(DISTINCT id) AS buying_players
    FROM fantasy.events
    WHERE amount <> 0.0
    GROUP BY item_code
),
sales_statistics AS (
    SELECT COUNT(transaction_id) AS total_sales
    FROM fantasy.events
    WHERE amount <> 0
),
players_statistics AS (
    SELECT COUNT(DISTINCT u.id) AS total_players
    FROM fantasy.users AS u
    JOIN fantasy.events AS e ON u.id = e.id
    WHERE e.amount <> 0.0
)
SELECT i.game_items,
    ist.absolute_sales,
    (ist.absolute_sales::REAL / (SELECT total_sales FROM sales_statistics)) AS relative_sales,
    (ist.buying_players::REAL / (SELECT total_players FROM players_statistics)) AS buying_players_share
FROM item_statistics AS ist
JOIN fantasy.items AS i ON ist.item_code = i.item_code
ORDER BY buying_players_share DESC;

-- game_items               |absolute_sales|relative_sales       |buying_players_share |
-- -------------------------+--------------+---------------------+---------------------+
-- Book of Legends          |       1004516|   0.7687008664869361|    0.884071630537229|
-- Bag of Holding           |        271875|   0.2080509898061711|   0.8676865076488074|
-- Necklace of Wisdom       |         13828| 0.010581808136238102|  0.11795838468788516|
-- Gems of Insight          |          3833|0.0029331841615707725|  0.06713550351627637|
-- Treasure Map             |          3084|0.0023600156416082084|  0.05459290944682085|
-- ...


-- Часть 2. Решение ad hoc-задачи
-- Задача: Зависимость активности игроков от расы персонажа:
WITH
registered_players AS (
	SELECT race_id,
		COUNT(DISTINCT id) AS total_registered_players
	FROM fantasy.users
	GROUP BY race_id 
),
users_statistics AS (
	SELECT u.race_id,
		COUNT(DISTINCT e.id) AS players_made_purchase
	FROM fantasy.events AS e 
	RIGHT JOIN fantasy.users AS u ON e.id = u.id
	WHERE e.amount <> 0.0
	GROUP BY u.race_id
),
paying_users_per_race AS (
	SELECT u.race_id,
		COUNT(DISTINCT u.id) AS paying_players_count
		FROM fantasy.users AS u 
		JOIN fantasy.events AS e ON u.id = e.id 
		WHERE u.payer = 1 AND e.amount <> 0.0
		GROUP BY u.race_id
),
purchases_statistics AS (
	SELECT u.race_id,
		COUNT(e.transaction_id) AS purchases_count,
		SUM(e.amount) AS total_amount,
		COUNT(DISTINCT e.id) AS players_count
	FROM fantasy.events AS e 
	JOIN fantasy.users AS u ON e.id = u.id 
	WHERE amount <> 0.0
	GROUP BY u.race_id
)
SELECT r.race,
	rp.total_registered_players,
	us.players_made_purchase,
	us.players_made_purchase::REAL / rp.total_registered_players AS players_made_purchase_share,
	pur.paying_players_count::REAL / us.players_made_purchase AS paying_players_share,
	ps.purchases_count::REAL / ps.players_count AS avg_purchases_per_player,
	ps.total_amount::REAL / ps.players_count  AS avg_cost_per_player,
	ps.total_amount::REAL / ps.purchases_count  AS avg_sum_cost_per_player
FROM registered_players AS rp 
LEFT JOIN users_statistics AS us ON rp.race_id = us.race_id 
LEFT JOIN paying_users_per_race AS pur ON us.race_id = pur.race_id
LEFT JOIN purchases_statistics AS ps ON rp.race_id = ps.race_id
RIGHT JOIN fantasy.race AS r ON rp.race_id = r.race_id;
 

-- race    |total_registered_players|players_made_purchase|players_made_purchase_share|paying_players_share|avg_purchases_per_player|avg_cost_per_player|avg_sum_cost_per_player|
--------+------------------------+---------------------+---------------------------+--------------------+------------------------+-------------------+-----------------------+
-- Elf     |                    2501|                 1543|          0.616953218712515| 0.16267012313674659|       78.79066753078419| 53761.726506804924|      682.3362232056196|
-- Northman|                    3562|                 2229|         0.6257720381807973| 0.18214445939883356|       82.10183938986093|  62518.17317182593|      761.4710417748149|
-- Angel   |                    1327|                  820|         0.6179351921627732| 0.16707317073170733|       106.8048780487805|  48665.68292682927|      455.6503767983558|
-- Orc     |                    3619|                 2276|         0.6289030118817353| 0.17398945518453426|       81.73813708260106|   41761.0474516696|     510.91264056419186|
-- Hobbit  |                    3648|                 2266|         0.6211622807017544|   0.176963812886143|        86.1288614298323|  47621.77228596646|      552.9130595179538|
-- Human   |                    6328|                 3921|         0.6196270543615676| 0.18005610813567968|      121.40219331803111|  48935.12879367508|     403.08274056863394|
-- Demon   |                    1229|                  737|         0.5996745321399511|  0.1994572591587517|       77.86974219810041|  41194.80868385346|      529.0220247429866|

