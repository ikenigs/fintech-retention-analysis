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
  MONTHLY_ACTIVITY AS (
    SELECT DISTINCT
      user_id,
      date(strftime('%Y-%m-01', creation_date)) AS month
    FROM TRX
  ),
  NEW_USERS AS (
    SELECT
      MIN(month) AS first_month,
      user_id
    FROM MONTHLY_ACTIVITY
    GROUP BY user_id
  ),
  REVIVED AS (
    SELECT DISTINCT
      this_month.month,
      this_month.user_id
    FROM MONTHLY_ACTIVITY AS this_month
    LEFT JOIN MONTHLY_ACTIVITY AS last_month
      ON  last_month.user_id = this_month.user_id
      AND last_month.month = date(this_month.month, '-1 month')
    WHERE last_month.user_id IS NULL
  )
-- 1️⃣ churners: active last month, not active this month
SELECT
  date(last_month.month, '+1 month') AS month,
  -COUNT(DISTINCT last_month.user_id) AS users,
  'churner' AS type
FROM MONTHLY_ACTIVITY AS last_month
LEFT JOIN MONTHLY_ACTIVITY AS this_month
  ON  this_month.user_id = last_month.user_id
  AND this_month.month = date(last_month.month, '+1 month')
WHERE this_month.user_id IS NULL
GROUP BY 1

UNION ALL

-- 2️⃣ new users: first month of activity
SELECT
  nu.first_month AS month,
  COUNT(DISTINCT nu.user_id) AS users,
  'new' AS type
FROM NEW_USERS AS nu
GROUP BY 1

UNION ALL

-- 3️⃣ revived users: came back after being inactive last month
SELECT
  r.month AS month,
  COUNT(DISTINCT r.user_id) AS users,
  'revived' AS type
FROM REVIVED AS r
LEFT JOIN NEW_USERS AS nu
  ON  nu.user_id = r.user_id
  AND nu.first_month = r.month
WHERE nu.user_id IS NULL
GROUP BY 1

UNION ALL

-- 4️⃣ recurring users: active this month, not new or revived
SELECT
  wa.month AS month,
  COUNT(DISTINCT wa.user_id) AS users,
  'recurring' AS type
FROM MONTHLY_ACTIVITY AS wa
LEFT JOIN NEW_USERS AS nu
  ON  nu.user_id = wa.user_id
  AND nu.first_month = wa.month
LEFT JOIN REVIVED AS r
  ON  r.user_id = wa.user_id
  AND r.month = wa.month
WHERE nu.user_id IS NULL
  AND r.user_id IS NULL
GROUP BY 1

ORDER BY 1 DESC, 3 ASC