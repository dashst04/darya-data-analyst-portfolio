/* Проект: анализ данных для агентства недвижимости
 *
 * Автор:Стогниева Дарья Александровна
 * Дата:10.10.2025
*/


-- 1. Найдем средние значения, минимумы и максимумы нижних и верхних порогов зарплаты
SELECT ROUND(AVG(salary_from)) AS avg_salary_from,
		ROUND(MAX(salary_from)) AS max_salary_from,
		ROUND(MIN(salary_from)) AS min_salary_from,
		ROUND(AVG(salary_to)) AS avg_salary_to,
		ROUND(MIN(salary_to)) AS min_salary_to,
		ROUND(MAX(salary_to)) AS max_salary_to
FROM public.parcing_table 

-- avg_salary_from|max_salary_from|min_salary_from|avg_salary_to|min_salary_to|max_salary_to|
-- ---------------+---------------+---------------+-------------+-------------+-------------+
--          109525|         398000|             50|       153847|        25000|       497500|

-- Средняя зарплата в категории «от» составляет около 109525 рублей, а в категории «до» - около 153847 рублей.
-- Минимальная предлагаемая зарплата начинается с 50 рублей, что, скорее всего, является ошибкой в данных.
-- Максимальная достигает 497500 рублей.



-- 2. Проверим, в каких компаниях сосредоточено наибольшее количество вакансий
SELECT employer,
		COUNT(name) AS total_offers
FROM public.parcing_table 
GROUP BY employer
ORDER BY total_offers DESC
LIMIT 10

-- employer                             |total_offers|
-- -------------------------------------+------------+
-- СБЕР                                 |         243|
-- WILDBERRIES                          |          43|
-- Ozon                                 |          34|
-- Банк ВТБ (ПАО)                       |          28|
-- Т1                                   |          26|
-- МАГНИТ, Розничная сеть               |          24|
-- МТС                                  |          22|
-- Okko                                 |          19|
-- Центральный банк Российской Федерации|          16|
-- Правительство Москвы                 |          15|

-- Наибольшее количество вакансий предоставляет СБЕР - один из крупнейших банков России.
-- На втором и третьем месте по количеству вакансий находятся WILDBERRIES и OZON - самые пополярные маркетлейсы в России.

-- 3. Найдем регионы, в которых сосредоточено наибольшее количество вакансий
SELECT area,
		COUNT(name) AS total_offers
FROM public.parcing_table 
GROUP BY area
ORDER BY total_offers DESC
LIMIT 10

-- area           |total_offers|
-- ---------------+------------+
-- Москва         |        1247|
-- Санкт-Петербург|         181|
-- Екатеринбург   |          51|
---

-- Чаще всего аналитиков данных и системных аналитиков ищут работодатели из самых крупных городов России - Москвы и Санкт-Петербурга.


-- 4. Проанализируем преобладающие типы занятости
SELECT employment,
		COUNT(id) AS offers_for_employment
FROM public.parcing_table
GROUP BY employment 
ORDER BY offers_for_employment DESC

-- employment         |offers_for_employment|
-- -------------------+---------------------+
-- Полная занятость   |                 1764|
-- Частичная занятость|                   16|
-- Стажировка         |                   16|
-- Проектная работа   |                    5|

-- В основном, компаниям требуются аналитики на полную занятость.


-- 5. Проанализируем, какие преобладают графики работы
SELECT schedule,
	COUNT(id) AS offers_for_employment
FROM public.parcing_table
GROUP BY schedule 
ORDER BY offers_for_employment DESC

-- schedule        |offers_for_employment|
-- ----------------+---------------------+
-- Полный день     |                 1441|
-- Удаленная работа|                  310|
-- Гибкий график   |                   41|
-- Сменный график  |                    9|

-- Более востребованы аналитики в офисе на полный рабочий день.
-- Также, много вакансий с предложением удаленного типа работы


-- 6. Изучим распределение грейдов (Junior, Middle, Senior) среди аналитиков данных и системных аналитиков.
SELECT experience,
		COUNT(id) AS offers_according_experience
FROM public.parcing_table
GROUP BY experience

-- experience           |offers_according_experience|
-- ---------------------+---------------------------+
-- Senior (6+ years)    |                         13|
-- Junior (no experince)|                        142|
-- Junior+ (1-3 years)  |                       1091|
-- Middle (3-6 years)   |                        555|

-- Больше всего работодателей ищут джунов с опытом от 1 года и миддлов с опытом от 3-х лет.
-- Примечательно, что вакансий на позицию синьера мало: вероятно, такие позиции закрываются существующим штатом мидлов.

-- 7. Выявим основных работодателей, предлагаемые зарплаты и условия труда для аналитиков.
SELECT employer,
		AVG(salary_from) AS avg_salary_from,
		AVG(salary_to) AS avg_salary_to,
		schedule,
		employment,
		COUNT(id) AS offers
FROM public.parcing_table
GROUP BY employer, schedule, employment
ORDER BY offers DESC


-- 8. Определим наиболее востребованные навыки (как жёсткие, так и мягкие) для различных грейдов и позиций.
SELECT key_skills_1,
       COUNT(*) AS num_mention
FROM public.parcing_table 
GROUP BY key_skills_1 
ORDER BY num_mention DESC;
-- key_skills_1                           |num_mention 
-- ---------------------------------------+-------------
--                                        |         383
--  Анализ данных                         |         312
--  SQL                                   |         161
--  Документация                          |          89
--  MS SQL                                |          87
-- ...

SELECT key_skills_2,
       COUNT(*) AS num_mention
FROM public.parcing_table 
GROUP BY key_skills_2 
ORDER BY num_mention DESC;

-- key_skills_2                                        |num_mention|
-- ----------------------------------------------------+-----------+
--                                                     |        641|
-- SQL                                                 |        318|
-- Python                                              |        142|
-- Коммуникация                                        |         64|
-- Анализ данных                                       |         62|
-- ...

SELECT key_skills_3,
       COUNT(*) AS num_mention
FROM public.parcing_table 
GROUP BY key_skills_3 
ORDER BY num_mention DESC;

-- key_skills_3                                          |num_mention|
-- ------------------------------------------------------+-----------+
--                                                       |        753|
-- SQL                                                   |        220|
-- Python                                                |        130|
-- Power BI                                              |         62|
-- Документация                                          |         61|
-- ...

SELECT key_skills_4,
       COUNT(*) AS num_mention
FROM public.parcing_table 
GROUP BY key_skills_4 
ORDER BY num_mention DESC;

-- key_skills_4                        |num_mention|
-- ------------------------------------+-----------+
--                                     |        864|
-- Python                              |        113|
-- SQL                                 |         61|
-- Документация                        |         47|
-- Работа с большим объемом информации |         47|
-- ...

-- Среди "жёстких" навыков наиболее востребованы языки программирования SQL и Python.
-- Также можно встретить такие навыки, как документация, коммуникация, Power BI и работа с большим объемом информации.


SELECT soft_skills_1,
       COUNT(*) AS num_mention
FROM public.parcing_table 
GROUP BY soft_skills_1 
ORDER BY num_mention DESC;

-- soft_skills_1         |num_mention|
-- ----------------------+-----------+
--                       |       1213|
-- Документация          |        234|
-- Коммуникация          |        181|
-- Аналитическое мышление|        109|
-- Проактивность         |         37|
-- ...

SELECT soft_skills_2,
       COUNT(*) AS num_mention
FROM public.parcing_table 
GROUP BY soft_skills_2 
ORDER BY num_mention DESC;

-- soft_skills_2          |num_mention|
-- -----------------------+-----------+
--                        |       1691|
--  Документация          |         46|
--  Аналитическое мышление|         32|
--  Проактивность         |         13|
--  Переговоры            |          9|
-- ...

SELECT soft_skills_3,
       COUNT(*) AS num_mention
FROM public.parcing_table 
GROUP BY soft_skills_3 
ORDER BY num_mention DESC;

-- soft_skills_3           |num_mention|
-- ------------------------+-----------+
--                         |       1779|
--  Аналитическое мышление |          9|
--  Проактивность          |          3|
--  Переговоры             |          3|
--  Креативность           |          3|
-- ...

SELECT soft_skills_4,
       COUNT(*) AS num_mention
FROM public.parcing_table 
GROUP BY soft_skills_4 
ORDER BY num_mention DESC;

-- soft_skills_4          |num_mention|
-- -----------------------+-----------+
--                        |       1796|
-- Внимание к деталям    |          3|
-- Аналитическое мышление|          2|

-- "Мягкие" навыки менее востребованы: это поле работадатели часто оставляют пустым.
-- Здесь можно отметить необходимыми навыки аналитического мышления и проактивность.
-- Документацию и коммуникацию относят как к "жестким", так и к "мягким" навыкам, что указывает на большую востребованность в работе аналитика.