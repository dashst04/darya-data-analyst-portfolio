/* Проект: анализ данных для агентства недвижимости
 *
 * Автор:Стогниева Дарья Александровна
 * Дата:30.11.2025
*/



-- Время активности объявлений
-- Определим аномальные значения (выбросы) по значению перцентилей:
WITH limits AS (
    SELECT
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats
),
-- Найдём id объявлений, которые не содержат выбросы, также оставим пропущенные данные:
filtered_id AS(
    SELECT id
    FROM real_estate.flats
    WHERE
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)
    ),
flats_data AS (SELECT f.*,
					CASE 
						WHEN f.city_id = '6X8I' THEN 'Санкт-Петербург'
						ELSE 'Ленинградская область'
					END AS city_or_region,
					CASE 
						WHEN a.days_exposition BETWEEN 1 AND 30 THEN 'до 1 месяца'
						WHEN a.days_exposition BETWEEN 31 AND 90 THEN 'от 1 месяца до трех'
						WHEN a.days_exposition BETWEEN 91 AND 180 THEN 'от 3 до 6 месяцев'
						WHEN a.days_exposition >= 181 THEN 'от 6 месяцев'
						ELSE 'без категории'
					END AS exposition_category,
					a.last_price::real / f.total_area AS cost_per_meter
				FROM real_estate.flats AS f
				LEFT JOIN real_estate.advertisement AS a ON a.id = f.id
				WHERE f.type_id = 'F8EM' AND EXTRACT(YEAR FROM a.first_day_exposition) BETWEEN 2015 AND 2018 AND f.id IN (SELECT * FROM filtered_id)
)
SELECT city_or_region,
	exposition_category,
	COUNT(id) AS ads_count,
	ROUND((COUNT(id)::real / SUM(COUNT(id)) OVER(PARTITION BY city_or_region)*100)::NUMERIC,2) AS ads_region_share,
	ROUND((AVG(cost_per_meter))::NUMERIC,2) AS avg_price_per_meter,
	ROUND((AVG(total_area))::NUMERIC,2) AS avg_total_area,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rooms) AS median_rooms,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY balcony) AS median_balcony
FROM flats_data
GROUP BY city_or_region,exposition_category
ORDER BY city_or_region,exposition_category;

-- Сезонность объявлений
-- Данные публикации объявлений:
-- Определим аномальные значения (выбросы) по значению перцентилей:
WITH limits AS (
    SELECT
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats
),
-- Найдём id объявлений, которые не содержат выбросы, также оставим пропущенные данные:
filtered_id AS(
    SELECT id
    FROM real_estate.flats
    WHERE
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)
    ),
flats_data AS (
				SELECT f.*,
					EXTRACT(MONTH FROM first_day_exposition) AS publication_month,
					a.last_price::real / f.total_area AS cost_per_meter
				FROM real_estate.flats AS f
				LEFT JOIN real_estate.advertisement AS a ON a.id = f.id
				WHERE f.type_id = 'F8EM' AND EXTRACT(YEAR FROM a.first_day_exposition) BETWEEN 2015 AND 2018 AND f.id IN (SELECT * FROM filtered_id)
)
SELECT publication_month,
	COUNT(id) AS ads_count,
	ROUND((COUNT(id) / SUM(COUNT(id)) OVER() * 100)::NUMERIC,2) AS ads_share, 
	ROUND((AVG(cost_per_meter))::NUMERIC,2) AS avg_cost_per_meter,
	ROUND((AVG(total_area))::NUMERIC,2) AS avg_total_area
FROM flats_data 
GROUP BY publication_month


-- Данные снятых объявлений:    
WITH limits AS (
    SELECT
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats
),
-- Найдём id объявлений, которые не содержат выбросы, также оставим пропущенные данные:
filtered_id AS(
    SELECT id
    FROM real_estate.flats
    WHERE
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)
    ),
flats_data AS (
				SELECT f.*,
					a.first_day_exposition::timestamp + ('1 day'::interval * a.days_exposition) AS removing_date,
					a.last_price::real / f.total_area AS cost_per_meter
				FROM real_estate.flats AS f
				LEFT JOIN real_estate.advertisement AS a ON a.id = f.id
				WHERE f.type_id = 'F8EM' AND EXTRACT(YEAR FROM a.first_day_exposition) BETWEEN 2015 AND 2018 AND f.id IN (SELECT * FROM filtered_id)
)
SELECT EXTRACT(MONTH FROM removing_date) AS removing_month,
	COUNT(id) AS ads_count,
	ROUND(((COUNT(id) / SUM(COUNT(id)) OVER())*100)::NUMERIC,2) AS ads_share, 
	ROUND((AVG(cost_per_meter))::NUMERIC,2) AS avg_cost_per_meter,
	ROUND((AVG(total_area))::NUMERIC,2) AS avg_total_area
FROM flats_data 
GROUP BY removing_month 
  