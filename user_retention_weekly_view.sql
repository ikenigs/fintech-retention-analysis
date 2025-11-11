WITH
  TRX AS (
    SELECT
      user_id,
      date(creation_date) AS creation_date,
      amount,
      trx_type
    FROM transactions
    WHERE lower(trim(trx_status)) = 'accepted'
  ),
  WEEKLY_ACTIVITY AS (
    SELECT DISTINCT
      user_id,
      -- Align each date to the first day (Sunday) of its week
      date(creation_date, '-' || strftime('%w', creation_date) || ' days') AS week
    FROM TRX
  ),
  NEW_USERS AS (
    SELECT
      MIN(week) AS first_week,
      user_id
    FROM WEEKLY_ACTIVITY
    GROUP BY user_id
  ),
  REVIVED AS (
    SELECT DISTINCT
      this_week.week,
      this_week.user_id
    FROM WEEKLY_ACTIVITY AS this_week
    LEFT JOIN WEEKLY_ACTIVITY AS last_week
      ON  last_week.user_id = this_week.user_id
      AND last_week.week = date(this_week.week, '-7 days')
    WHERE last_week.user_id IS NULL
  )
-- 1️⃣ churners: active last week, not active this week
SELECT
  date(last_week.week, '+7 days') AS week,
  -COUNT(DISTINCT last_week.user_id) AS users,
  'churner' AS type
FROM WEEKLY_ACTIVITY AS last_week
LEFT JOIN WEEKLY_ACTIVITY AS this_week
  ON  this_week.user_id = last_week.user_id
  AND this_week.week = date(last_week.week, '+7 days')
WHERE this_week.user_id IS NULL
GROUP BY 1

UNION ALL

-- 2️⃣ new users: first week of activity
SELECT
  nu.first_week AS week,
  COUNT(DISTINCT nu.user_id) AS users,
  'new' AS type
FROM NEW_USERS AS nu
GROUP BY 1

UNION ALL

-- 3️⃣ revived users: came back after being inactive the previous week
SELECT
  r.week AS week,
  COUNT(DISTINCT r.user_id) AS users,
  'revived' AS type
FROM REVIVED AS r
LEFT JOIN NEW_USERS AS nu
  ON  nu.user_id = r.user_id
  AND nu.first_week = r.week
WHERE nu.user_id IS NULL
GROUP BY 1

UNION ALL

-- 4️⃣ recurring users: active this week, not new or revived
SELECT
  wa.week AS week,
  COUNT(DISTINCT wa.user_id) AS users,
  'recurring' AS type
FROM WEEKLY_ACTIVITY AS wa
LEFT JOIN NEW_USERS AS nu
  ON  nu.user_id = wa.user_id
  AND nu.first_week = wa.week
LEFT JOIN REVIVED AS r
  ON  r.user_id = wa.user_id
  AND r.week = wa.week
WHERE nu.user_id IS NULL
  AND r.user_id IS NULL
GROUP BY 1

ORDER BY 1 DESC, 3 ASC