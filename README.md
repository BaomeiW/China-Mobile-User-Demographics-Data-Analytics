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

### **Create tables for importing data (*first drop tables if exists*):**

```
DROP TABLE IF EXISTS app_events;
DROP TABLE IF EXISTS app_labels;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS gender_age_train;
DROP TABLE IF EXISTS label_categories;
DROP TABLE IF EXISTS phone_brand;
DROP TABLE IF EXISTS new_phone_brand;

CREATE TABLE app_events(event_id BIGINT, app_id BIGINT, is_installed VARCHAR, is_active VARCHAR);
CREATE TABLE app_labels(app_id BIGINT, label_id INTEGER);
CREATE TABLE events(event_id BIGINT, device_id BIGINT, event_time TIMESTAMP, longitude NUMERIC, latitude NUMERIC);
CREATE TABLE gender_age_train(device_id BIGINT, gender VARCHAR, age INTEGER, age_group VARCHAR);
CREATE TABLE label_categories(label_id INTEGER, category VARCHAR);
CREATE TABLE phone_brand(device_id BIGINT, phone_brand VARCHAR, device_model VARCHAR);

```

### **An execution successful screenshot shown as belown:**

![Optional Text](https://github.com/BaomeiW/China-Mobile-User-Demographics-Data-Analytics/blob/main/results/create table execution result.png)






