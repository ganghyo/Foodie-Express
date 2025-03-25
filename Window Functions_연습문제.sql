-- 1. 사용자별 쿼리를 실행한 총 횟수를 구하는 쿼리를 작성해주세요.
-- SELECT
--   *,
--   count(query_date) OVER(PARTITION BY user) as cnt
-- FROM `advanced.query_logs`
-- ORDER BY user

-- 2. 주차별로 팀 내에서 쿼리를 많이 실행한 수를 구하고, 랭킹을 구해주세요.
-- SELECT
--   *,
--   RANK() OVER(PARTITION BY week_number, team ORDER BY query_cnt desc) as query_rank
-- FROM (
--   SELECT
--     team,
--     user,
--     count(user) as query_cnt,
--     EXTRACT(WEEK FROM query_date) as week_number
--   FROM `advanced.query_logs`
--   GROUP BY ALL
-- )
-- QUALIFY query_rank = 1
-- ORDER BY week_number, query_cnt desc

-- 3. 쿼리 실행 시점 기준으로 일주일 전에 실행한 쿼리 수를 별도의 컬럼으로 확인할 수 있도록 쿼리를 작성해주세요.
-- SELECT
--   *,
--   LAG(query_cnt, 1) OVER(PARTITION BY user ORDER BY week_number)
-- FROM (
--   SELECT
--     team,
--     user,
--     count(query_date) as query_cnt,
--     EXTRACT(WEEK FROM query_date) as week_number
--   FROM `advanced.query_logs`
--   GROUP BY ALL
-- )
-- ORDER BY week_number

-- 4. 시간의 흐름에 따라 일자별로 유저가 실행한 누적 쿼리 수를 작성해주세요.
-- SELECT
--   *,
--   SUM(query_cnt) OVER(PARTITION BY user ORDER BY query_date)
-- FROM (
--   SELECT
--     *,
--     count(user) as query_cnt
--   FROM `advanced.query_logs`
--   GROUP BY ALL
-- )
-- ORDER BY user, query_date

-- 5. 주문 횟수가 NULL 인 경우, 이전 날짜의 값으로 채워지는 쿼리를 작성해주세요.
WITH raw_data AS (
  SELECT DATE '2024-05-01' AS date, 15 AS number_of_orders UNION ALL
  SELECT DATE '2024-05-02', 13 UNION ALL
  SELECT DATE '2024-05-03', NULL UNION ALL
  SELECT DATE '2024-05-04', 16 UNION ALL
  SELECT DATE '2024-05-05', NULL UNION ALL
  SELECT DATE '2024-05-06', 18 UNION ALL
  SELECT DATE '2024-05-07', 20 UNION ALL
  SELECT DATE '2024-05-08', NULL UNION ALL
  SELECT DATE '2024-05-09', 13 UNION ALL
  SELECT DATE '2024-05-10', 14 UNION ALL
  SELECT DATE '2024-05-11', NULL UNION ALL
  SELECT DATE '2024-05-12', NULL
)
-- SELECT
--   *,
--   IF(number_of_orders IS NULL, lag_order, number_of_orders) as fill_lag_order
-- FROM (
--   SELECT
--     date,
--     LAG(number_of_orders) OVER(ORDER BY date) as lag_order,
--     number_of_orders
--   FROM raw_data
--   ORDER BY date
-- )

# FIRST_VALUE, LAST_VALUE 사용할 때, NULL 을 제외하고 싶으면 IGNORE_NULLS 사용
-- SELECT
--   *,
--   LAST_VALUE(number_of_orders IGNORE NULLS) OVER(ORDER BY date) as fill_last_order
-- FROM raw_data

-- 6. 위의 데이터에서 2일 전~현재 평균을 구하는 쿼리를 작성해주세요.
-- SELECT
--   *,
--   ROUND(AVG(fill_last_order) OVER(ORDER BY date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) as avg_2day
-- FROM (
--   SELECT
--     *,
--     LAST_VALUE(number_of_orders IGNORE NULLS) OVER(ORDER BY date) as fill_last_order
--   FROM raw_data
-- )