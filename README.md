# 🧮 Fintech User Retention Analysis (SQLite + Python + Power BI)

### 📊 Overview  
This project analyzes **user acquisition, retention and churn dynamics** in a simulated fintech environment.  
It builds an end-to-end data pipeline using **SQLite** as a local analytical database, where **SQL logics** are implemented to create **views** for analysis, **Python** to load data in **Power BI** which is used for visualization and insight generation.

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
| **SQLite** | Lightweight analytical database for local computation and views creation |
| **SQL** | Retention logic and classification |
| **Python (Pandas + SQLite3)** | Data loading to Power BI |
| **Power BI Desktop** | Dashboarding and insights |

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
