# Medical Appointment No-Show Analysis (SQL + Power BI)

An end-to-end analysis of **110,514 medical appointments** to understand why patients miss their appointments and what a clinic can do about it. Data was cleaned and analysed in **MySQL**, then presented in a **2-page Power BI dashboard**.

> **No-show rate: 20.19%** | **Unique patients: 62,294** | **Average wait: 10.18 days**

## Dashboard Preview

### Page 1: Overview


![Dashboard page 1](Dashboard%20page%201.png)



### Page 2: Deep Dive


![Dashboard page 2](Dashboard%20page%202.png)



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

| Column | Meaning |
|---|---|
| `wait_days` | Days between scheduling and appointment |
| `wait_group` | Same day / 1-7 days / 8-30 days / Over 30 days |
| `age_group` | Child (0-12), Teen (13-19), Adult (20-39), Middle (40-59), Senior (60+) |
| `appointment_weekday` | Day of the week of the appointment |
| `missed` | 1 if the patient did not show up, otherwise 0 |

## 3. Approach

1. **Data cleaning (MySQL):** loaded the raw CSV into `appointments_raw`, then built a clean `appointments` table. Removed 13 invalid rows (5 appointments dated before their scheduling date and 8 with invalid ages). Kept `patient_id` as text because some IDs were in scientific notation, and created the `missed` flag.
2. **SQL analysis:** answered 11 business questions with SQL (see the table below and the `.sql` file).
3. **Dashboard (Power BI):** built DAX measures (Total Appointments, Unique Patients, No-Show Rate, Average Wait Days) and a 2-page dashboard with slicers for gender, age group and scholarship.
4. **Insight-led design:** every chart title states the finding, so the dashboard can be read quickly.

## 4. SQL Analysis

### Questions answered

| # | Business question | Key result |
|---|---|---|
| 1 | What is the overall no-show rate? | 20.19% |
| 2 | How does wait time affect no-shows? | 4.65% (same day) to 33.00% (over 30 days) |
| 3 | Which age group misses most? | Teens, 25.95% |
| 4 | Does gender matter? | Little effect |
| 5 | Does the weekday matter? | Small effect |
| 6 | Which neighbourhoods have the highest no-show rate? | Santos Dumont, 28.92% |
| 7 | Do scholarship patients miss more? | 23.74% vs 19.80% |
| 8 | Do chronic conditions change no-shows? | Slightly fewer no-shows |
| 9 | Do SMS reminders reduce no-shows? | Overall 27.58% vs 16.70% (misleading) |
| 10 | Does SMS help within each wait group? | Same or fewer no-shows with SMS |
| 11 | Does wait time drive no-shows in every age group? | Yes |

### Example queries

**No-show rate by wait group**
```sql
SELECT wait_group,
       COUNT(*) AS appointments,
       ROUND(AVG(missed) * 100, 2) AS no_show_rate
FROM appointments
GROUP BY wait_group
ORDER BY FIELD(wait_group, 'Same day', '1-7 days', '8-30 days', 'Over 30 days');
```

| Wait group | No-show rate |
|---|---|
| Same day | 4.65% |
| 1-7 days | 24.14% |
| 8-30 days | 31.72% |
| Over 30 days | 33.00% |

**No-show rate by age group**
```sql
SELECT age_group,
       COUNT(*) AS appointments,
       ROUND(AVG(missed) * 100, 2) AS no_show_rate
FROM appointments
GROUP BY age_group;
```

| Age group | No-show rate |
|---|---|
| Child (0-12) | 20.47% |
| Teen (13-19) | 25.95% |
| Adult (20-39) | 23.13% |
| Middle (40-59) | 18.81% |
| Senior (60+) | 15.30% |

**SMS effect within each wait group (checking for Simpson's paradox)**
```sql
SELECT wait_group,
       sms_received,
       COUNT(*) AS appointments,
       ROUND(AVG(missed) * 100, 2) AS no_show_rate
FROM appointments
GROUP BY wait_group, sms_received
ORDER BY wait_group, sms_received;
```

| Wait group | No SMS | SMS sent |
|---|---|---|
| Same day | 4.65% | (no SMS sent) |
| 1-7 days | 24.36% | 23.76% |
| 8-30 days | 35.55% | 29.13% |
| Over 30 days | 37.51% | 30.20% |

**Top neighbourhoods by no-show rate**
```sql
SELECT neighbourhood,
       COUNT(*) AS appointments,
       ROUND(AVG(missed) * 100, 2) AS no_show_rate
FROM appointments
GROUP BY neighbourhood
HAVING COUNT(*) >= 100
ORDER BY no_show_rate DESC
LIMIT 7;
```

| Neighbourhood | No-show rate |
|---|---|
| Santos Dumont | 28.92% |
| Santa Clara | 26.48% |
| Itararé | 26.27% |
| Jesus de Nazareth | 24.40% |
| Ilha do Príncipe | 23.48% |
| Caratoíra | 23.04% |
| Andorinhas | 22.94% |

The full set of queries is in `medical_appointment_noshow_analysis.sql`.

## 5. Results

| Factor | Finding |
|---|---|
| Wait time | No-show rate rises from **4.65%** (same day) to **33.00%** (over 30 days) |
| Age | Teens miss most (**25.95%**); seniors least (**15.30%**) |
| Scholarship | **23.74%** with scholarship vs **19.80%** without |
| SMS (overall) | **27.58%** with SMS vs **16.70%** without |
| SMS (within the same wait group) | Equal or lower no-shows with SMS |
| Gender, weekday, alcoholism | Little effect |
| Highest-risk neighbourhood | Santos Dumont (**28.92%**) |

### Insights

- **Wait time is the strongest driver.** The longer the gap between booking and appointment, the more likely the patient is to miss it. This holds in every age group.
- **Teens are the highest-risk age group,** and no-shows fall steadily with age.
- **SMS looks harmful overall but is not.** SMS reminders are mostly sent for appointments booked further ahead, which already have higher no-show rates. Within each wait group, patients who received an SMS miss the same or fewer appointments (Simpson's paradox).
- **Scholarship patients miss more.** Patients with chronic conditions miss slightly fewer, which may partly reflect age, since older patients have more chronic conditions.
- **Neighbourhood matters.** Some areas run above 25%, though small neighbourhoods should be read with their appointment counts.

## 6. Recommendations

1. **Shorten booking lead times** where possible, or send extra reminders for appointments booked more than 8 days ahead.
2. **Target reminders** at higher-risk groups: teenagers, scholarship patients and high-risk neighbourhoods.
3. **Consider controlled overbooking** for long-wait slots, based on expected no-show rates.
4. **Run an SMS A/B test** to measure the true effect of reminders, since this data cannot prove cause.

## 7. Limitations

- The data shows association, not causation.
- SMS was not assigned randomly, so its effect is confounded by wait time.
- Small neighbourhoods have few appointments, so their rates are less reliable.
- The data covers one region and a short period (2016), so results may not apply elsewhere.
- Rows with invalid ages or dates were removed, which slightly reduces the sample.

## 8. Next Steps

- Add a minimum-volume filter for neighbourhood rates.
- Test whether the chronic-condition effect
