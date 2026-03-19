/* Проект: Анализ активности доноров проекта DonorSearch
 *
 * Автор: Стогниева Дарья Александровна
 * Дата: 25.10.2025
*/

-- 1. Определим регионы с наибольшим количеством зарегистрированных доноров.
SELECT region,
		COUNT(*) AS total_donats
FROM donorsearch.user_anon_data
GROUP BY region
ORDER BY total_donats DESC
LIMIT 5

-- region                         |total_donats|
-- -------------------------------+------------+
-- Город не указан                |      100574|
-- Россия, Москва                 |       37819|
-- Россия, Санкт-Петербург        |       13137|
-- Россия, Татарстан, Казань      |        6610|
-- Украина, Киевская область, Киев|        3541|

-- Большая часть доноров не указали свой регион.
-- Города с наибольшем количеством зарегестрированных доноров - это Москва, Санкт-Петербург, Казань и Киев.
-- Они являются самыми крупными городами


-- 2. Изучим динамику общего количества донаций в месяц за 2022 и 2023 годы.
SELECT DATE_TRUNC('month', donation_date)::date AS donation_month,
		COUNT(*) AS count_donation
FROM donorsearch.donation_anon
WHERE DATE_TRUNC('year',donation_date) IN('2022-01-01','2023-01-01')
GROUP BY donation_month
ORDER BY donation_month

--donation_month|count_donation|
----------------+--------------+
--    2022-01-01|          1977|
--    2022-02-01|          2109|
--    2022-03-01|          3002|
--    2022-04-01|          3223|
--    2022-05-01|          2414|
--    2022-06-01|          2792|
--    2022-07-01|          2836|
--    2022-08-01|          2987|
--    2022-09-01|          3089|
--    2022-10-01|          3265|
--    2022-11-01|          3156|
--    2022-12-01|          3303|
--    2023-01-01|          2795|
--    2023-02-01|          3056|
--    2023-03-01|          3523|
--    2023-04-01|          2951|
--    2023-05-01|          2568|
--    2023-06-01|          2651|
--    2023-07-01|          2276|
--    2023-08-01|          2433|
--    2023-09-01|          2240|
--    2023-10-01|          2117|
--    2023-11-01|          1509|

-- нет данных за последний месяц 2023 года;
-- с июня 2023 года количество донаций уменьшилось;
-- наибольшее количество доннаций пришлось на апрель 2022 года;
-- меньше всего донаций было в ноябре 2023 года.


-- 3. Определим наиболее активных доноров в системе, учитывая только данные о зарегистрированных и подтвержденных донациях.
SELECT DISTINCT id,
		confirmed_donations 
FROM donorsearch.user_anon_data
ORDER BY confirmed_donations DESC
LIMIT 5

-- id    |confirmed_donations|
-- ------+-------------------+
-- 235391|                361|
-- 273317|                257|
-- 201521|                236|
-- 211970|                236|
-- 132946|                227|

-- Самый активный донор - с ID 235391.

-- 4. Оценим, как система бонусов влияет на зарегистрированные в системе донации.
WITH donor_activity AS
  (SELECT u.id,
          u.confirmed_donations,
          COALESCE(b.user_bonus_count, 0) AS user_bonus_count
   FROM donorsearch.user_anon_data u
   LEFT JOIN donorsearch.user_anon_bonus b ON u.id = b.user_id)
SELECT CASE
           WHEN user_bonus_count > 0 THEN 'Получили бонусы'
           ELSE 'Не получали бонусы'
       END AS статус_бонусов,
       COUNT(id) AS количество_доноров,
       AVG(confirmed_donations) AS среднее_количество_донаций
FROM donor_activity
GROUP BY статус_бонусов;

-- статус_бонусов     | количество_доноров | среднее_количество_донаций 
-- -------------------|--------------------|----------------------------
-- Получили бонусы    | 21108              | 13.90
-- Не получали бонусы | 256491             | 0.53


-- Доноры, которые получили бонусы, в среднем делают значительно больше донаций (около 14 донаций), чем те, кто не получил бонусы (около 1 донации).
-- Это свидетельствует о сильном положительном влиянии программ лояльности на активность доноров.
-- Всего 21108 доноров получили бонусы, что значительно меньше по сравнению с общей базой доноров (256491). 

-- 5. Исследуем вовлечение новых доноров через социальные сети. Узнаем, сколько по каким каналам пришло доноров, и среднее количество донаций по каждому каналу.
SELECT CASE
           WHEN autho_vk THEN 'ВКонтакте'
           WHEN autho_ok THEN 'Одноклассники'
           WHEN autho_tg THEN 'Telegram'
           WHEN autho_yandex THEN 'Яндекс'
           WHEN autho_google THEN 'Google'
           ELSE 'Без авторизации через соцсети'
       END AS социальная_сеть,
       COUNT(id) AS количество_доноров,
       ROUND(AVG(confirmed_donations),2) AS среднее_количество_донаций
FROM donorsearch.user_anon_data
GROUP BY социальная_сеть;

-- социальная_сеть              |количество_доноров|среднее_количество_донаций|
-- -----------------------------+------------------+--------------------------+
-- Google                       |             14292|                      1.08|
-- Telegram                     |               481|                      1.17|
-- Без авторизации через соцсети|            113266|                      0.71|
-- ВКонтакте                    |            127254|                      0.91|
-- Одноклассники                |              6410|                      0.56|
-- Яндекс                       |              4133|                      1.73|

-- Наибольшее количество доноров пришло с ВКонтакте, однако среднее количество донаций не говорит о высокой эффективности платформы. 
-- Это говорит о том, что больше половины доноров пришедших с ВКонтакте не участвуют в донациях.
-- Самыми эффективными, с точки зрения среднего количества донаций, являются Яндекс и Telegram.
-- Однако, с этих платформ пришло наименьшее количество доноров. Поэтому, на этих платформах следует сосредоточить маркетинковые кампания для привлечения более вовлеченных доноров. 

-- 6. Сравним активность однократных доноров со средней активностью повторных доноров.
WITH donor_activity AS (
  SELECT user_id,
         COUNT(*) AS total_donations,
         (MAX(donation_date) - MIN(donation_date)) AS activity_duration_days,
         (MAX(donation_date) - MIN(donation_date)) / (COUNT(*) - 1) AS avg_days_between_donations,
         EXTRACT(YEAR FROM MIN(donation_date)) AS first_donation_year,
         EXTRACT(YEAR FROM AGE(CURRENT_DATE, MIN(donation_date))) AS years_since_first_donation
  FROM donorsearch.donation_anon
  GROUP BY user_id
  HAVING COUNT(*) > 1
)
SELECT first_donation_year,
       CASE 
           WHEN total_donations BETWEEN 2 AND 3 THEN '2-3 донации'
           WHEN total_donations BETWEEN 4 AND 5 THEN '4-5 донаций'
           ELSE '6 и более донаций'
       END AS donation_frequency_group,
       COUNT(user_id) AS donor_count,
       ROUND(AVG(total_donations)) AS avg_donations_per_donor,
       ROUND(AVG(activity_duration_days)) AS avg_activity_duration_days,
       ROUND(AVG(avg_days_between_donations)) AS avg_days_between_donations,
       ROUND(AVG(years_since_first_donation)) AS avg_years_since_first_donation
FROM donor_activity
GROUP BY first_donation_year, donation_frequency_group
ORDER BY first_donation_year, donation_frequency_group;
 							
-- first_donation_year|donation_frequency_group|donor_count|avg_donations_per_donor|avg_activity_duration_days|avg_days_between_donations|avg_years_since_first_donation|
-- -------------------+------------------------+-----------+-----------------------+--------------------------+--------------------------+------------------------------+
--                 201|6 и более донаций       |          1|                     26|                    663670|                     26546|                          1824|
--                 207|6 и более донаций       |          1|                     37|                    661775|                     18382|                          1818|
--                 208|6 и более донаций       |          1|                      7|                    660907|                    110151|                          1817|
--                 214|6 и более донаций       |          1|                     39|                    658841|                     17337|                          1811|
--                1019|6 и более донаций       |          1|                     33|                    366097|                     11440|                          1006|
--                1900|6 и более донаций       |          1|                      7|                     45136|                      7522|                           126|
--                1919|6 и более донаций       |          1|                     51|                     37445|                       748|                           106|
--                1970|2-3 донации             |          4|                      3|                     17440|                     10908|                            56|
-- ...

-- Можно заметить, что данные имеют серьезные аномалии, в дате первой донации, это говорит об ошибках в данных.
-- В связи с аномалиями, точные цифры назвать трудно, но можно предположить, что повторные доноры имеют большую вовлеченность в течение длительного времени.

-- 7. Сравним данные о планируемых донациях с фактическими данными, чтобы оценить эффективность планирования.
WITH planned_donations AS (
  SELECT DISTINCT user_id, donation_date, donation_type
  FROM donorsearch.donation_plan
),
actual_donations AS (
  SELECT DISTINCT user_id, donation_date
  FROM donorsearch.donation_anon
),
planned_vs_actual AS (
  SELECT
    pd.user_id,
    pd.donation_date AS planned_date,
    pd.donation_type,
    CASE WHEN ad.user_id IS NOT NULL THEN 1 ELSE 0 END AS completed
  FROM planned_donations pd
  LEFT JOIN actual_donations ad ON pd.user_id = ad.user_id AND pd.donation_date = ad.donation_date
)
SELECT
  donation_type,
  COUNT(*) AS total_planned_donations,
  SUM(completed) AS completed_donations,
  ROUND(SUM(completed) * 100.0 / COUNT(*), 2) AS completion_rate
FROM planned_vs_actual
GROUP BY donation_type;

-- donation_type|total_planned_donations|completed_donations|completion_rate|
-- -------------+-----------------------+-------------------+---------------+
-- Безвозмездно |                  22903|               4950|          21.61|
-- Платно       |                   3299|                429|          13.00|

-- Можно заметить, что процент выполнения планов донаций низкий для обоих типов доноров: 21.61% для безвозмездных и 13.00% для платных.
-- Это указывает на необходимость повышения вовлечённости доноров, особенно платных.

-- Итоговые рекомендации:

-- Усилить маркетинговые кампании в регионах с низкой активностью доноров, чтобы увеличить их вовлечённость.
-- Расширить охват программ лояльности.
-- Вовлечение через социальные сети: активнее использовать платформы Яндекс и Telegram для привлечения доноров.
-- Сосредоточиться на удержании и мотивации однократных доноров, чтобы увеличить их активность и сделать их постоянными участниками донорских программ.

