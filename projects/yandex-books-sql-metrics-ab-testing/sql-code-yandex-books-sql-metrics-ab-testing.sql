/* Проект «Сервис доставки еды»
 * Автор: Стогниева Дарья Александровна 
 * Дата: 09.04.26
*/

-- Часть 1. Расчет метрик
-- Расчёт MAU авторов
SELECT aut.main_author_name,
    COUNT(DISTINCT aud.puid) AS mau 
FROM bookmate.audition AS aud 
JOIN bookmate.content AS c ON aud.main_content_id = c.main_content_id
JOIN bookmate.author AS aut ON c.main_author_id = aut.main_author_id
WHERE EXTRACT(MONTH FROM aud.msk_business_dt_str) = 11
GROUP BY EXTRACT(MONTH FROM aud.msk_business_dt_str), aut.main_author_name
ORDER BY mau DESC
LIMIT 3;

-- Андрей Усачёв собрал больше всего уникальных читателей и слушателей в ноябре.

-- Расчёт MAU произведений
SELECT c.main_content_name,
    c.published_topic_title_list,
    aut.main_author_name,
    COUNT(DISTINCT aud.puid) AS mau 
FROM bookmate.audition AS aud 
JOIN bookmate.content AS c ON aud.main_content_id = c.main_content_id
JOIN bookmate.author AS aut ON c.main_author_id = aut.main_author_id
WHERE EXTRACT(MONTH FROM aud.msk_business_dt_str) = 11
GROUP BY main_content_name, published_topic_title_list, main_author_name
ORDER BY mau DESC
LIMIT 3;

-- Все три произведения, которые были самыми популярными в ноябре, написаны для детей.

-- Расчёт Retention Rate
WITH 
cohort AS (
    SELECT DISTINCT puid
    FROM bookmate.audition
    WHERE msk_business_dt_str::date = '2024-12-02'
),

daily_retention AS (
    SELECT 
        c.puid,
        a.msk_business_dt_str::date - '2024-12-02'::date AS day_since_install
    FROM bookmate.audition a
    JOIN cohort AS c ON a.puid = c.puid
    WHERE a.msk_business_dt_str::date >= '2024-12-02'
)

SELECT day_since_install,
    COUNT(DISTINCT puid) AS retained_users,
    ROUND(1.0 * COUNT(DISTINCT puid) / MAX(COUNT(DISTINCT puid)) OVER (),2) AS retention_rate
FROM daily_retention
GROUP BY day_since_install
ORDER BY day_since_install;

-- На пятый день активности возвращаемость пользователей была минимальной.

-- Расчёт LTV
WITH paying_users AS (
    SELECT 
        puid,
        usage_geo_id,
        DATE_TRUNC('month', msk_business_dt_str::date) AS month,
        399 AS revenue
    FROM bookmate.audition
    GROUP BY puid, usage_geo_id, DATE_TRUNC('month', msk_business_dt_str::date)
)

SELECT 
    g.usage_geo_id_name AS city,
    COUNT(DISTINCT pu.puid) AS total_users,
    ROUND(SUM(pu.revenue)::numeric / COUNT(DISTINCT pu.puid), 2) AS ltv
FROM paying_users pu
JOIN bookmate.geo g ON pu.usage_geo_id = g.usage_geo_id
WHERE g.usage_geo_id_name IN ('Москва', 'Санкт-Петербург')
GROUP BY g.usage_geo_id_name;

-- В Москве больше пользователей, чем в Санкт-Петербурге, и их средний LTV выше.

-- Расчёт средней выручки прослушанного часа - аналог среднего чека
SELECT (DATE_TRUNC('month', msk_business_dt_str))::date AS month,
        COUNT(DISTINCT puid) AS mau,
        ROUND(SUM(hours)::numeric,2) AS hours,
    ROUND(((COUNT(DISTINCT puid)*399)/ROUND(SUM(hours)))::numeric,2)
FROM bookmate.audition
WHERE msk_business_dt_str::date >= '2024-09-01'
  AND msk_business_dt_str::date < '2024-12-01'
GROUP BY MONTH;

-- Средняя выручка за час чтения или прослушивания с сентября по ноябрь падает.


-- Часть 2. Проверка гипотезы: подготовка данных
-- Приведем исходные данные из таблиц к такому виду, который будет пригодным для проверки гипотезы в Python. 
-- Отберем пользователей только из Москвы и Санкт-Петербурга и выведем их активность, то есть сумму часов.
SELECT g.usage_geo_id_name AS city,
    aud.puid,
    SUM(aud.hours) AS hours 
FROM bookmate.audition AS aud 
JOIN bookmate.geo AS g ON aud.usage_geo_id=g.usage_geo_id
WHERE g.usage_geo_id_name = 'Москва' OR g.usage_geo_id_name = 'Санкт-Петербург'
GROUP BY g.usage_geo_id_name, aud.puid;
