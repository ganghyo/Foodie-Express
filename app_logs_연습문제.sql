-- 1. app_logs 데이터의 배열을 풀어주세요.
# event_params<key, value<string_value, int_value>>
-- WITH base as (
--   SELECT
--     event_date,
--     event_timestamp,
--     event_name,
--     ep.key as key,
--     ep.value.string_value as string_value,
--     ep.value.int_value as int_value,
--     user_id
--   FROM `advanced.app_logs`, UNNEST(event_params) as ep
--   WHERE event_date = '2022-08-01'
-- )
-- SELECT
--   event_date,
--   event_name,
--   count(user_id)
-- FROM base
-- GROUP BY ALL
-- ORDER BY count(user_id)

-- 2. app_logs 데이터 PIVOT
-- SELECT
--   -- * EXCEPT(event_params)
--   event_date,
--   event_timestamp,
--   event_name,
--   user_id,
--   MAX(IF(param.key = 'firebase_screen', param.value.string_value, NULL)) as firebase_screen,
--   MAX(IF(param.key = 'food_id', param.value.int_value, NULL)) as food_id,
--   MAX(IF(param.key = 'session_id', param.value.string_value, NULL)) as session_id
-- FROM `advanced.app_logs`, UNNEST(event_params) as param
-- WHERE event_date = '2022-08-01'
-- GROUP BY ALL
-- limit 100

-- 3. 퍼널 데이터 event_step 생성
# 이벤트 단계 -> step_number 생성 => screen_view: welcome, home, food_category, restaurant, cart / click_payment
WITH base as (
  SELECT
    event_date,
    event_timestamp,
    event_name,
    user_id,
    user_pseudo_id,
    MAX(IF(event_param.key = 'firebase_screen', event_param.value.string_value, NULL)) as firebase_screen,
    MAX(IF(event_param.key = 'session_id', event_param.value.string_value, NULL)) as session_id
  FROM `advanced.app_logs`, UNNEST(event_params) as event_param
  WHERE event_date BETWEEN '2022-08-01' AND '2022-08-18'
  GROUP BY ALL
)
, filter_event_name_and_screen as (
  SELECT
    * EXCEPT(event_name, firebase_screen, event_timestamp),
    CONCAT(event_name, "-", firebase_screen) as event_name_with_screen,
    DATETIME(TIMESTAMP_MICROS(event_timestamp)) as event_datetime
  FROM base
  WHERE event_name IN ('screen_view', 'click_payment')
)
SELECT
  event_name_with_screen,
  CASE
    WHEN event_name_with_screen = 'screen_view-welcome' THEN 1
    WHEN event_name_with_screen = 'screen_view-home' THEN 2
    WHEN event_name_with_screen = 'screen_view-food_category' THEN 3
    WHEN event_name_with_screen = 'screen_view-restaurant' THEN 4
    WHEN event_name_with_screen = 'screen_view-cart' THEN 5
    WHEN event_name_with_screen = 'click_payment-cart' THEN 6
    ELSE NULL
  END as step_number,
  count(distinct user_pseudo_id) as user_cnt
FROM filter_event_name_and_screen
GROUP BY ALL
HAVING step_number IS NOT NULL
ORDER BY step_number

-- 4. 퍼널 데이터 피벗하기
-- WITH base as (
--   SELECT
--     event_date,
--     event_timestamp,
--     event_name,
--     user_id,
--     user_pseudo_id,
--     MAX(IF(event_param.key = 'firebase_screen', event_param.value.string_value, NULL)) as firebase_screen,
--     MAX(IF(event_param.key = 'session_id', event_param.value.string_value, NULL)) as session_id
--   FROM `advanced.app_logs`, UNNEST(event_params) as event_param
--   WHERE event_date BETWEEN '2022-08-01' AND '2022-08-18'
--   GROUP BY ALL
-- )
-- , filter_event_name_and_screen as (
--   SELECT
--     * EXCEPT(event_name, firebase_screen, event_timestamp),
--     CONCAT(event_name, "-", firebase_screen) as event_name_with_screen,
--     DATETIME(TIMESTAMP_MICROS(event_timestamp)) as event_datetime
--   FROM base
--   WHERE event_name IN ('screen_view', 'click_payment')
-- )
-- , funnel_data as (
--   SELECT
--     event_date,
--     event_name_with_screen,
--     CASE
--       WHEN event_name_with_screen = 'screen_view-welcome' THEN 1
--       WHEN event_name_with_screen = 'screen_view-home' THEN 2
--       WHEN event_name_with_screen = 'screen_view-food_category' THEN 3
--       WHEN event_name_with_screen = 'screen_view-restaurant' THEN 4
--       WHEN event_name_with_screen = 'screen_view-cart' THEN 5
--       WHEN event_name_with_screen = 'click_payment-cart' THEN 6
--       ELSE NULL
--     END as step_number,
--     count(distinct user_pseudo_id) as user_cnt
--   FROM filter_event_name_and_screen
--   GROUP BY ALL
--   HAVING step_number IS NOT NULL
--   ORDER BY event_date
-- )
-- SELECT
--   event_date,
--   MAX(IF(event_name_with_screen = 'screen_view-welcome', user_cnt, NULL)) as `screen_view-welcome`,
--   MAX(IF(event_name_with_screen = 'screen_view-home', user_cnt, NULL)) as `screen_view-home`,
--   MAX(IF(event_name_with_screen = 'screen_view-food_category', user_cnt, NULL)) as `screen_view_food-category`,
--   MAX(IF(event_name_with_screen = 'screen_view-restaurant', user_cnt, NULL)) as `screen_view-restaurant`,
--   MAX(IF(event_name_with_screen = 'screen_view-cart', user_cnt, NULL)) as `screen_view-cart`,
--   MAX(IF(event_name_with_screen = 'click_payment-cart', user_cnt, NULL)) as `click_payment-cart`
-- FROM funnel_data
-- GROUP BY event_date
-- ORDER BY event_date