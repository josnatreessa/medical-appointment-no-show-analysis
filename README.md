# Medical Appointment No-Show Analysis (SQL + Power BI)

An end-to-end analysis of **110,514 medical appointments** to understand why patients miss their appointments and what a clinic can do about it. Data was cleaned and analysed in **MySQL**, then presented in a **2-page Power BI dashboard**.

> **No-show rate: 20.19%** | **Unique patients: 62,294** | **Average wait: 10.18 days**

---

## 1. Business Problem

Missed appointments waste doctors' time, leave slots empty that other patients could have used, and delay care. About **1 in 5 appointments** in this dataset was a no-show.

The clinic management wants to know:

1. Which factors are most strongly linked to no-shows?
2. Which patient groups and locations carry the highest risk?
3. Do SMS reminders actually reduce no-shows?
4. What practical steps could reduce missed appointments?

## 2. Dataset

| Item | Detail |
|---|---|
| Source | Kaggle: Medical Appointment No Shows (KaggleV2-May-2016.csv, Brazil) |
| Records | 110,514 appointments after cleaning |
| Patients | 62,294 unique patients |
| Key fields | Gender, age, neighbourhood, scholarship, hypertension, diabetes, alcoholism, handicap, SMS received, scheduled date, appointment date, no-show |

**Columns I created:**

- `wait_days`: days between scheduling and appointment
- `wait_group`: Same day / 1-7 days / 8-30 days / Over 30 days
- `age_group`: Child (0-12), Teen (13-19), Adult (20-39), Middle (40-59), Senior (60+)
- `appointment_weekday`: day of the week of the appointment
- `missed`: 1 if the patient did not show up, otherwise 0

## 3. Approach

1. **Data cleaning (MySQL):** loaded the raw CSV into `appointments_raw`, then built a clean `appointments` table. Removed 13 invalid rows
