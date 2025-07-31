# 🏥 Healthcare Data Analysis with PostgreSQL

This project is a healthcare data analytics exercise using synthetic EHR (Electronic Health Records) datasets. It demonstrates skills in SQL, PostgreSQL, data cleaning, feature engineering, and exploratory data analysis on patient-related healthcare data.

---

## 📁 Project Overview

We worked with four core tables:

- **`patients`** – Demographic and clinical details of patients  
- **`encounters`** – Patient visits and associated healthcare events  
- **`procedures`** – Medical procedures undergone by patients  
- **`payers`** – Insurance provider information  

We duplicated each table to create working versions (`patients1`, `encounters1`, etc.) for cleaning and analysis without altering the raw data.

---

## 🧹 Data Cleaning (patients1)

The following columns were dropped from `patients1` due to redundancy or high sparsity:

- `suffix`, `prefix`, `maiden`
- `lat`, `lon`
- `zip`, `address`

These steps simplified the dataset for cleaner analysis and model-readiness.

---

## 🧠 Feature Engineering

- ✅ **Age column** was calculated using:
  - `deathdate` if present
  - Otherwise, we assumed the patient is alive and used `'2022-12-31'` as the reference date
- 🧮 Populated `age` via `EXTRACT(YEAR FROM AGE(...))` and updated `patients1`

---

## 📊 Exploratory Data Analysis (EDA)

### 🔹 Patient Overview

- Total Patients: **974**
- Alive: **820** (84%)
- Deceased: **154** (16%)
- Max Age: **103**
- Average Age: **72.8**
- Median Age: **75**

### 🔹 Gender Distribution

| Gender | Count | % |
|--------|-------|----|
| Male   | 494   | 50.72% |
| Female | 480   | 49.28% |

### 🔹 Marital Status

| Status | Meaning | Count | % |
|--------|---------|-------|----|
| M      | Married | 788   | 80.94% |
| S      | Single  | 189   | 19.40% |
| NULL   | Unknown | 1     | 0.10% |

### 🔹 Race Distribution

| Race     | % of Total |
|----------|------------|
| White    | ~70%       |
| Black    | ~17%       |
| Asian    | ~9%        |
| Other    | ~2%        |
| Hawaiian | ~2%        |
| Native   | ~1%        |

### 🔹 Ethnicity

| Ethnicity     | % |
|---------------|----|
| Non-Hispanic  | 80.39% |
| Hispanic      | 19.61% |

### 🔹 Intersectional Analysis

- Race × Ethnicity  
- Gender × Ethnicity  

These cross-tab analyses helped understand demographic patterns better.

---

## 🌍 Birthplace Insights

- Most patients were born in **Boston, Massachusetts, US**
- Birthplace data is heavily concentrated geographically

---

## 🧪 Encounter Analysis (encounters1)

### 🔹 Overview

- Total Encounters: **27,891**
- Distinct Patients: **974**
- Average Encounters per Patient: **28.64**
- Median Encounters per Patient: **14**
- 95% of patients had fewer than **100** encounters

### 🔹 Yearly Encounter Distribution

- Data spans from **2011 to 2022**
- **2014** recorded the highest number of encounters
- Some encounters span across different years (e.g., start in Dec and stop in Jan of the following year)

### 🔹 Encounter Class Duration Check

- **Ambulatory** and **Outpatient** classes are generally short (under a few hours)
- However, anomalies exist (e.g., outpatient encounters spanning months or even years), likely due to data entry issues

### 🔹 Encounter Class Breakdown (Yearly)

For each year, the share of encounter classes (e.g., ambulatory, outpatient, emergency, etc.) was computed:

- **Ambulatory** was the dominant class in most years
- **Outpatient** led in **2021**

<img width="689" height="319" alt="Screenshot 2025-07-31 174253" src="https://github.com/user-attachments/assets/5a9e04ae-3405-4dab-969b-5d45053dde67" />



### 🔹 Duration-Based Analysis

- **95.87%** of all encounters lasted **less than 24 hours**
- Only **4.13%** were over 24 hours, suggesting that most visits were short-term consultations or procedures

---

## 🔧 Tech Stack

- **PostgreSQL**
- **DBeaver**
- **pgAdmin 4**
- **SQL (CTEs, CASE, aggregation, window functions)**

---

## ✅ What I Learned

- Advanced SQL techniques (`PERCENTILE_CONT`, `PERCENTILE_DISC`, `CASE`, `AGE`, `EXTRACT`)
- Data quality validation through temporal comparisons
- Anomaly detection in timestamp-based event records
- Encounter trend and class-based segmentation
- Building multi-layered SQL queries for real-world healthcare data analysis

---

## 🔭 Next Steps

- Analyze `procedures1` to tie procedures to patient encounters
- Dive into cost data: `BASE_ENCOUNTER_COST`, `TOTAL_CLAIM_COST`, and `PAYER_COVERAGE`
- Join patient + encounter + payer data to understand healthcare journeys and insurance implications
- Develop dashboards from aggregated queries

---

**NB:** The dataset was downloaded from [Maven Analytics](https://mavenanalytics.io/).
