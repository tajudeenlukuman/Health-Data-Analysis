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

- `suffix`
- `prefix`
- `lat`, `lon`
- `maiden`
- `zip`
- `address`

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

| Race | % of Total |
|------|------------|
| White | ~70% |
| Black | ~17% |
| Asian | ~9% |
| Other | ~2% |
| Hawaiian | ~2% |
| Native | ~1% |

### 🔹 Ethnicity

| Ethnicity        | % |
|------------------|----|
| Non-Hispanic     | 80.39% |
| Hispanic         | 19.61% |

### 🔹 Intersectional Analysis

- Race × Ethnicity
- Gender × Ethnicity

These cross-tab analyses helped understand demographic patterns better.

---

## 📍 Birthplace Insights

- Most patients were born in **Boston, Massachusetts, US**
- Birthplace data is heavily concentrated geographically

---

## 🔧 Tech Stack

- **PostgreSQL**
- **pgAdmin 4**
- **SQL (CTEs, CASE, aggregation, window functions)**

---

## ✅ What I Learned

- Advanced SQL techniques (e.g., `PERCENTILE_CONT`, `PERCENTILE_DISC`)
- Using `CASE`, `EXTRACT`, and `AGE()` for date operations
- Data cleaning strategies and when to drop vs transform
- Demographic segmentation using `GROUP BY` + window functions
- Creating reusable and safe analysis workflows with table copies

---

## 🧠 Next Steps

- Analyze `encounters1` and `procedures1` to link visits to patient outcomes
- Cost analysis: `BASE_ENCOUNTER_COST`, `TOTAL_CLAIM_COST`, `PAYER_COVERAGE`
- Explore the payer system and insurance patterns
- Join across tables for more holistic patient journeys

---

NB: The dataset was downloaded from https://mavenanalytics.io/
