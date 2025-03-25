-- 1. array_exercise 테이블에서 각 영화별로 장르를 UNNEST해서 보여주세요.
-- SELECT
--   title,
--   genre
-- FROM `advanced.array_exercises` as ae
-- CROSS JOIN UNNEST(genres) as genre

-- 2. 각 영화별로 배우와 배역을 보여주세요.
-- SELECT
--   title,
--   ac.actor as actor,
--   ac.character as character
-- FROM `advanced.array_exercises`
-- CROSS JOIN UNNEST(actors) as ac

-- 3. 각 영화별로 배우, 배역, 장르를 출력하세요.
-- SELECT
--   title,
--   ac.actor,
--   ac.character,
--   genre
-- FROM `advanced.array_exercises`, UNNEST(genres) as genre, UNNEST(actors) as ac
-- -- CROSS JOIN UNNEST(genres) as genre
-- -- CROSS JOIN UNNEST(actors) as ac


-- 4. orders 테이블에서 유저별로 주문 금액의 합계를 PIVOT 해주세요.
-- SELECT
--   order_date,
--   SUM(IF(user_id=1, amount, NULL)) as user_1,
--   SUM(IF(user_id=2, amount, NULL)) as user_2,
--   SUM(IF(user_id=3, amount, NULL)) as user_3
-- FROM `advanced.orders`
-- GROUP BY order_date
-- ORDER BY order_date

-- 5. 날짜별로 유저들의 주문 금액의 합계를 PIVOT 해주세요.
# ANY_VALUE: NULL을 제외한 임의의 값을 선택
# (0일 경우 0이 출력될 수 있음) -> MAX 사용
-- SELECT
--   user_id,
--   ANY_VALUE(IF(order_date='2023-05-01', amount, NULL)) as `2023-05-01`,
--   ANY_VALUE(IF(order_date='2023-05-02', amount, NULL)) as `2023-05-02`,
--   ANY_VALUE(IF(order_date='2023-05-03', amount, NULL)) as `2023-05-03`,
--   ANY_VALUE(IF(order_date='2023-05-04', amount, NULL)) as `2023-05-04`,
--   ANY_VALUE(IF(order_date='2023-05-05', amount, NULL)) as `2023-05-05`
-- FROM `advanced.orders`
-- GROUP BY user_id
-- ORDER BY user_id

-- 6. 사용자별, 날짜별로 주문이 있다면 1, 없다면 0을 PIVOT 해주세요.
-- SELECT
--   user_id,
--   MAX(IF(order_date='2023-05-01', 1, 0)) as `2023-05-01`,
--   MAX(IF(order_date='2023-05-02', 1, 0)) as `2023-05-02`,
--   MAX(IF(order_date='2023-05-03', 1, 0)) as `2023-05-03`,
--   MAX(IF(order_date='2023-05-04', 1, 0)) as `2023-05-04`,
--   MAX(IF(order_date='2023-05-05', 1, 0)) as `2023-05-05`
-- FROM `advanced.orders`
-- GROUP BY user_id