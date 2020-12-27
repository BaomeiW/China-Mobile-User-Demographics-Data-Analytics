# **China-Mobile-User-Demographics-Data-Analytics:**

## **Introduction:**

The objective of this project is to find the most popular phone brands and device models in gender and age groups.

## **Data source:**

https://www.kaggle.com/chinapage/china-mobile-user-gemographics

The datasets contain 8 CSV files, 34 columns and the total data size is 1.18 GB.

app_events.csv
app_labels.csv
events.csv
gender_age_test.csv
gender_age_train.csv
label_categories.csv
phone_brand_device_model.csv
sample_submission.csv

## **Abstract:**

1. Review datasets, find out the relationships between datasets.
2. Create tables, import raw data.
3. Clean data, set PK, FK constrains for tables.
4. implement data analysis.

## **All SQL queries for this project is shown below:**

### **Drop tables if exists:**

```
DROP TABLE IF EXISTS app_events;

DROP TABLE IF EXISTS app_labels;

DROP TABLE IF EXISTS events;

DROP TABLE IF EXISTS gender_age_train;

DROP TABLE IF EXISTS label_categories;

DROP TABLE IF EXISTS phone_brand;

DROP TABLE IF EXISTS new_phone_brand;
```
