# 🧮 Fintech User Retention Analysis (SQLite + Python + Power BI)

### 📊 Overview  
This project analyzes **user retention and churn dynamics** in a simulated fintech environment.  
It builds an end-to-end data pipeline using **SQLite** as a local analytical database and **Power BI** for visualization and insight generation.

Users are classified weekly and monthly into:
- 🆕 **New** – first time active  
- 🔁 **Recurring** – continuously active  
- 🔄 **Revived** – returned after inactivity  
- ❌ **Churned** – active previously, but not anymore  

The goal is to understand behavioral patterns, retention trends, and product health through cohort-style analytics.

---

### 🧱 Tech Stack
| Component | Purpose |
|------------|----------|
| **SQLite** | Lightweight analytical database for local computation |
| **Python (Pandas + SQLite3)** | Data loading and view creation inside Power BI |
| **Power BI Desktop** | Dashboarding and insights |
| **SQL** | Retention logic and classification |
| **GitHub** | Version control and documentation |

---

### 🧩 SQL Logic Summary

The retention views are built in layers using CTEs:

| CTE | Purpose |
|------|----------|
| **TRX** | Selects successful transactions (`trx_status = 'accepted'`) |
| **MONTHLY_ACTIVITY / WEEKLY_ACTIVITY** | Identifies when each user was active |
| **NEW_USERS** | Finds first active period per user |
| **REVIVED** | Detects users reactivated after inactivity |
| **Final UNION** | Combines all groups: new, recurring, revived, churner |

**Key classification logic:**

| Category | Definition | SQL Condition |
|-----------|-------------|---------------|
| 🆕 New | First active period | `MIN(period)` |
| 🔁 Recurring | Active now & previously | Not new, not revived |
| 🔄 Revived | Active this period but inactive last | `LEFT JOIN last_period IS NULL` |
| ❌ Churner | Active last period, inactive now | `LEFT JOIN next_period IS NULL` |

---

### 📊 Dataset Summary

A synthetic dataset of **250,000 transactions** was created in Python to simulate real-world fintech usage behavior:

- **Rows:** 250,000  
- **Users:** ~25,000 unique (`final_user_id`)  
- **Date range:** `2024-01-01 → 2024-12-31`  

**Fields:**
| Column | Description |
|---------|--------------|
| `final_user_id` | Unique user identifier |
| `creation_date` | Transaction date (YYYY-MM-DD) |
| `amount` | Transaction amount (skewed distribution between 5–500) |
| `trx_type` | Transaction type (`payment`, `topup`, `withdrawal`, `transfer`) |
| `final_status` | Transaction outcome (`accepted` ~90%, `declined` ~10%) |

---

**Report:**

You can view the interactive Power BI dashboard [here](https://app.powerbi.com/reportEmbed?reportId=ae02ae89-ea42-4e03-a180-aecc36d90fe5&autoAuth=true&ctid=a8eec281-aaa3-4dae-ac9b-9a398b9215e7)

---

**Key insights:**
The Power BI dashboard provides a clear overview of user retention dynamics throughout the year. By combining new, recurring, revived, and churned user segments, it reveals how the active user base evolves month by month.
Key trends show that most users remain engaged over multiple periods, while revived users represent an important source of reactivation after inactivity. The churn curve helps identify moments of user drop-off, supporting proactive retention strategies.
Together, these insights allow business teams to monitor user lifecycle health, measure engagement effectiveness, and assess the impact of growth or re-engagement initiatives in real time.
