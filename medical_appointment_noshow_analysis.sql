CREATE DATABASE medical_noshow;
USE medical_noshow;
CREATE TABLE appointments_raw( PatientId varchar(30),AppointmentId varchar(30),
Gender varchar(5), ScheduledDay varchar(30), AppointmentDay varchar(30),
Age varchar(10), Neighbourhood varchar(100), Scholarship varchar(5),
Hipertension varchar(5), Diabetes varchar(5), Alcoholism varchar(5),
Handcap varchar (5), SMS_recieved varchar(5),`No-show` varchar(5)
)CHARACTER SET utf8mb4;
SET GLOBAL local_infile =1;
USE medical_noshow;
LOAD DATA LOCAL INFILE 'C:/Users/GEO/Desktop/JOSNA/KaggleV2-May-2016.csv'
INTO TABLE appointments_raw
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
Select * from appointments_raw;
Select count(*) from appointments_raw;
Select count(*) as total_rows,count( distinct PatientId )as unique_patients,
count(distinct AppointmentId) as unique_appointments from appointments_raw;
Select PatientId, Age from appointments_raw where age='Null';
Select PatientId, Age from appointments_raw where age='';
Select min(age) as min_age from appointments_raw;
Select * from appointments_raw where age<0;
SELECT MIN(CAST(Age AS SIGNED)) AS min_age,
       MAX(CAST(Age AS SIGNED)) AS max_age
FROM appointments_raw;
Select PatientId from appointments_raw where PatientId like '%E-%'
lIMIT 10;
Alter table appointments_raw rename column PatientId to patient_id,
rename column AppointmentId to appointment_id, rename column Gender
to gender,rename column ScheduledDay to scheduled_day, rename column
AppointmentDay to appointment_day, rename column Age to age, rename
column Neighbourhood to neighbourhood, rename column Scholarship to
scholarship, rename column Hipertension to hipertention, rename
column Diabetes to diabetes, rename column Alcoholism to alcoholism,
rename column Handcap to handicap, rename column SMS_recieved to
sms_recieved, rename column `No-Show` to no_show;
Alter table appointments_raw rename column hipertention to hipertension;
select patient_id,scholarship,hipertension from appointments_raw
where scholarship='' and hipertension='';
USE medical_noshow;
Alter table appointments_raw rename column hipertension to hypertension;
Alter table appointments_raw rename column sms_recieved to sms_received;
CREATE TABLE appointments AS
SELECT
    patient_id,
    CAST(appointment_id AS UNSIGNED)                           AS appointment_id,
    gender,
    STR_TO_DATE(scheduled_day,  '%Y-%m-%dT%H:%i:%sZ')          AS scheduled_day,
    DATE(STR_TO_DATE(appointment_day, '%Y-%m-%dT%H:%i:%sZ'))   AS appointment_day,
    CAST(age AS SIGNED)                                        AS age,
    TRIM(neighbourhood)                                        AS neighbourhood,
    CAST(scholarship AS SIGNED)                                AS scholarship,
    CAST(hypertension AS SIGNED)                               AS hypertension,
    CAST(diabetes AS SIGNED)                                   AS diabetes,
    CAST(alcoholism AS SIGNED)                                 AS alcoholism,
    CAST(handicap AS SIGNED)                                   AS handicap,
    CAST(sms_received AS SIGNED)                               AS sms_received,
    no_show,
    CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END                AS missed
FROM appointments_raw
WHERE CAST(age AS SIGNED) BETWEEN 0 AND 100;
Select *  from appointments;
Select count(*) from appointments where appointment_day is null 
or scheduled_day is null;
Select count(*) from appointments where appointment_day<DATE 
(scheduled_day);
SET SQL_SAFE_UPDATES=0;
delete from appointments where appointment_day<DATE 
(scheduled_day);
SET SQL_SAFE_UPDATES=1;
Select count(*) from appointments;
Alter table appointments add column wait_days int,
add column appointment_weekday varchar(10),
add column age_group varchar(20),add column
wait_group varchar(20);
SET SQL_SAFE_UPDATES=0;
Update appointments set  wait_days= datediff(appointment_day, DATE(scheduled_day)),
appointment_weekday =dayname(appointment_day), age_group= CASE
WHEN age< 13 then 'Child(0-12)'
WHEN age< 20 then 'Teen(13-19)'
WHEN age< 40 then 'Adult(20-39)'
WHEN age< 60 then 'Middle(40-59)' else 'Senior (60+)' end,
wait_group= CASE
WHEN datediff(appointment_day, DATE(scheduled_day)) =0 then 'Same day'
WHEN datediff(appointment_day, DATE(scheduled_day)) <=7 then '1-7 days'
WHEN datediff(appointment_day, DATE(scheduled_day)) <=30 then '8-30 days'
else 'Over 30 days' end;
Select *  from appointments;
Select count(*) from appointments;
----# Total appointments =110514----
Select count(distinct patient_id)as unique_patients from appointments;
----# Total Number of unique patients = 62294----
Select count(appointment_id) from appointments
where no_show='Yes';
----# No of appointments missed =22311---
Select count(*) as total_appointments,
sum(case when no_show='Yes' then 1 else 0 end),
round(sum(case when no_show='Yes' then 1 else 0 end) *100.0
/count(*),2) from appointments;
----#Overall no_show rate = 20.19%----
Select *  from appointments;
Select round(avg(datediff(appointment_day,scheduled_day)),2) as avg_waiting_time_in_days
from appointments;
----# Average waiting time in days = 10.18 i.e. 10 days, 4 hours---
Select age_group, count(*) as total_appointments,
sum(case when no_show='Yes' then 1 else 0 end),
round(sum(case when no_show='Yes' then 1 else 0 end)*100.0
/count(*),2) from appointments group by age_group;
----#No-show rate by age group: No-shows peak among teens (25.95%), followed by young adults (23.13%).
----#Children are lower at 20.47%. After young adulthood, the rate keeps falling with age,
----#  and seniors are the most reliable at 15.30%.----
Select gender,count(*) as total_appointments,
sum(case when no_show='Yes' then 1 else 0 end),
round(sum(case when no_show='Yes' then 1 else 0 end)*100.0
/count(*),2) from appointments group by gender;
----#Female patients account for the majority of total appointments (71,829) compared to male patients (38,685).
----#No-show rates between genders are nearly identical, with females at 20.31% and males at 19.96%.
----#Gender has a negligible impact on appointment attendance behavior, as both closely mirror the overall 20.19% baseline.
Select *  from appointments;
SELECT 'Hypertension' AS condition_name,
hypertension AS has_condition,
COUNT(*) AS total_appointments,
SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) AS missed_appointments,
ROUND(SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS no_show_rate
FROM appointments
GROUP BY hypertension
UNION ALL
SELECT 'Diabetes',
diabetes,
COUNT(*),
SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END),
ROUND(SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM appointments
GROUP BY diabetes
UNION ALL
SELECT 'Alcoholism',
alcoholism,
COUNT(*),
SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END),
ROUND(SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM appointments
GROUP BY alcoholism
UNION ALL
SELECT 'Handicap',
handicap,
COUNT(*),
SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END),
ROUND(SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM appointments
GROUP BY handicap;
----#No-show rate by health condition: Patients with hypertension (17.30% vs 20.90%)
----#and diabetes (18.00% vs 20.36%) miss fewer appointments than patients without these conditions,
---#likely because these patients skew older and older patients are more reliable.
----#Alcoholism has no effect (20.15% vs 20.19%). Handicap level 1 shows a lower rate (17.73%),
----#while levels 3 and 4 have too few appointments (13 and 3) to draw conclusions.----
Select *  from appointments;
Select scholarship,count(*) as total_appointments,
sum(case when no_show='Yes' then 1 else 0 end),
round(sum(case when no_show='Yes' then 1 else 0 end)*100.0
/count(*),2) from appointments group by scholarship;
----# No-show rate by scholarship (welfare program enrollment): Patients enrolled in the welfare program miss more appointments (23.74%)
----#than those not enrolled (19.80%), a gap of 3.94 percentage points.
----#The data shows an association only; it does not explain why enrolled patients miss more appointments.----
Select wait_group,count(*) as total_appointments,
sum(case when no_show='Yes' then 1 else 0 end),
round(sum(case when no_show='Yes' then 1 else 0 end)*100.0
/count(*),2) from appointments group by wait_group;
----#No-show rate by wait group: Waiting time is the strongest driver of missed appointments. 
----#Same-day appointments have a no-show rate of only 4.65%, rising to 24.14% for 1-7 days, 31.72% for 8-30 days and 33.00% for over 30 days.
----#Same-day bookings account for about 35% of all appointments, which lowers the overall rate. 
----#Patients who wait more than a week are about 6 to 7 times more likely to miss than same-day patients.----
Select appointment_weekday,count(*) as total_appointments,
sum(case when no_show='Yes' then 1 else 0 end),
round(sum(case when no_show='Yes' then 1 else 0 end)*100.0
/count(*),2) from appointments group by appointment_weekday;
----#No-show rate by appointment weekday: No-show rates are fairly stable across weekdays, 
----#ranging from 19.34% (Thursday) to 21.23% (Friday), a spread of under 2 percentage points. 
----#Saturday shows the highest rate (23.08%) but has too few appointments to be reliable, and there are no Sunday appointments. 
----#Day of the week has only a minor effect on attendance.----
Select *  from appointments;
Select sms_received,count(*) as total_appointments,
sum(case when no_show='Yes' then 1 else 0 end),
round(sum(case when no_show='Yes' then 1 else 0 end)*100.0
/count(*),2) from appointments group by sms_received;
----#No-show rate by SMS reminder: Patients who received an SMS reminder had a higher no-show rate (27.58%) than those who did not (16.70%). 
----#This does not show that reminders increase no-shows. Same-day appointments, which have very low no-show rates, 
----#rarely receive SMS reminders, so the SMS group is mostly patients with longer waits, who are more likely to miss. 
----#The raw comparison is confounded by wait time.----
Select *  from appointments;
Select neighbourhood,count(*) as total_appointments,
sum(case when no_show='Yes' then 1 else 0 end),
round(sum(case when no_show='Yes' then 1 else 0 end)*100.0
/count(*),2) as no_show_rate from appointments group by neighbourhood 
having count(*)>=500 order by no_show_rate desc
limit 10;
----#Top 10 neighbourhoods by no-show rate (minimum 500 appointments): Santos Dumont has the highest rate (28.92%), 
----#followed by Santa Clara (26.48%) and Itararé (26.27%). All ten neighbourhoods are above the overall 20.19%, 
----#ranging up to about 8.7 percentage points higher. By contrast, the lowest rates are around 15.7% (Do Cabral). 
----#Neighbourhood differences may partly reflect patient mix and waiting times, so they show where no-shows are concentrated, not why.----







