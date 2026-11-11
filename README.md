# Портфолио Data Analyst

Привет! Меня зовут Дарья.

В этом репозитории собраны мои проекты по **анализу данных и продуктовой аналитике**.

В проектах я работаю с пользовательским поведением, продуктовыми и бизнес-метриками, воронками, когортами, юнит-экономикой и A/B-тестированием. Отдельное внимание уделяю подготовке данных, статистическому анализу и формированию выводов, которые могут использоваться для принятия продуктовых и бизнес-решений.

## 🛠️ Инструменты

* **Python:** Pandas, NumPy, Matplotlib, Seaborn, SciPy, Statsmodels, PySpark
* **SQL:** PostgreSQL, ClickHouse
* **Оркестрация:** Apache Airflow
* **BI:** Yandex DataLens
* **Таблицы:** Google Sheets
* **Среды и инструменты:** Jupyter Notebook, DBeaver

## 📊 Основные навыки

* Предобработка и исследовательский анализ данных
* SQL-анализ и работа с базами данных
* Расчёт продуктовых метрик: DAU, WAU, MAU, ARPU, ARPPU, AOV, Conversion Rate, Retention Rate
* Когортный анализ и анализ удержания пользователей
* Анализ пользовательских воронок
* Сегментация пользователей
* Юнит-экономика: CAC, LTV, ROI, Payback Period
* Анализ эффективности маркетинговых каналов
* A/B-тестирование и статистическая проверка гипотез
* Bootstrap-анализ
* Поиск аномалий в данных
* Построение аналитических дашбордов
* Формирование продуктовых гипотез и рекомендаций
* Разработка ETL-процессов и автоматизация обработки данных

## 📁 Проекты

### [Все проекты →](./projects)

Подробный каталог проектов с навигацией по инструментам, навыкам и направлениям анализа.

### SQL и базы данных

**[Анализ пользовательского поведения и контента в Яндекс Книгах](https://github.com/dashst04/darya-data-analyst-portfolio/tree/main/projects/clickhouse-yandex-books-user-behavior)**

`SQL` `ClickHouse` `DBeaver`

Анализ пользовательской активности, популярности контента, поведения на мобильных платформах и корректности тематической разметки. Использованы CTE, JOIN, оконные функции, работа с массивами, сегментация пользователей и статистический анализ.

**[Анализ игровой экономики «Секреты Темнолесья»](https://github.com/dashst04/darya-data-analyst-portfolio/tree/main/projects/darkwood-game-sql-analysis)**

`SQL` `DBeaver`

Анализ монетизации и поведения игроков: доля платящих пользователей, внутриигровые покупки, популярность предметов, аномальные транзакции и различия между сегментами игроков.

### Продуктовая аналитика и бизнес-метрики

**[Анализ продуктовых метрик и юнит-экономики маркетплейса](https://github.com/dashst04/darya-data-analyst-portfolio/tree/main/projects/marketplace-sql-python-product-analytics)**

`SQL` `Python` `Pandas` `Jupyter Notebook`

Комплексный анализ пользовательской активности, воронки, монетизации и эффективности маркетинговых каналов. Рассчитаны DAU, WAU, MAU, ARPU, ARPPU, AOV, Retention, CAC, ROI и Payback Period. Выполнена сегментация пользователей и сформулированы продуктовые гипотезы.

**[Анализ юнит-экономики контентной платформы](https://github.com/dashst04/darya-data-analyst-portfolio/tree/main/projects/content-platform-unit-economics-analysis)**

`Python` `Pandas` `Jupyter Notebook`

Когортный анализ и оценка эффективности привлечения пользователей. Рассчитаны CAC, LTV, ROI, Retention и Conversion Rate, исследована окупаемость маркетинговых каналов и причины стагнации выручки.

**[Анализ ключевых бизнес-метрик сервиса доставки еды](https://github.com/dashst04/darya-data-analyst-portfolio/tree/main/projects/food-delivery-sql-datalens-dashboard)**

`SQL` `PostgreSQL` `Yandex DataLens`

Расчёт и визуализация DAU, Conversion Rate, Average Check, LTV и Retention Rate. Создан интерактивный дашборд для мониторинга ключевых продуктовых и бизнес-метрик.

**[Анализ данных салона красоты в Google Sheets](https://github.com/dashst04/darya-data-analyst-portfolio/tree/main/projects/google-sheets-beauty-salon-analysis)**

`Google Sheets`

Предобработка и анализ финансовых данных салона, исследование доходов и расходов, промокампаний, товаров и услуг. Использованы формулы, сводные таблицы и визуализация.

### A/B-тестирование и статистика

**[A/B-тестирование онбординга в финтех-приложении](https://github.com/dashst04/darya-data-analyst-portfolio/tree/main/projects/fintech-app-ab-testing)**

`Python` `Pandas` `SciPy` `Statsmodels` `Jupyter Notebook`

Анализ результатов A/B-теста нового онбординга. Проведена проверка корректности эксперимента, статистическое тестирование, bootstrap-анализ, исследование воронки и результатов по пользовательским сегментам.

**[A/B-тестирование рекомендательной системы](https://github.com/dashst04/darya-data-analyst-portfolio/tree/main/projects/recommendation-system-ab-testing-python)**

`Python`

Анализ эксперимента по внедрению нового алгоритма рекомендаций: подготовка данных, сравнение тестовой и контрольной групп, статистическая проверка гипотез и оценка влияния изменений на пользовательскую активность.

### Обработка данных и автоматизация

**[Автоматизация обработки данных о поездках Яндекс Такси](https://github.com/dashst04/darya-data-analyst-portfolio/tree/main/projects/yandex-taxi-pyspark-airflow)**

`PySpark` `Apache Airflow` `ClickHouse`

Разработка автоматизированного ETL-процесса для обработки данных о поездках. С помощью PySpark сформирована витрина с показателями по способам оплаты, а в Airflow настроен ежедневный запуск обработки после появления нового файла в S3. Результаты загружаются в ClickHouse.

## Контакты

Буду рада предложениям о сотрудничестве и интересным задачам в области аналитики данных и продуктовой аналитики.

* **Email:** [dashst.04@gmail.com](mailto:dashst.04@gmail.com)
* **Telegram:** [@DashSt04](https://t.me/DashSt04)
* **LinkedIn:** [Darya Stogniyeva](https://linkedin.com/in/darya-stogniyeva-a16614437/)
