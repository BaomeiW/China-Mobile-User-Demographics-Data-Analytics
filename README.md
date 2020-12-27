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

### **Create tables for importing data (*first drop table if exists*):**

```SQL
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

### **An execution successful screenshot shown as below:**

![](https://github.com/BaomeiW/China-Mobile-User-Demographics-Data-Analytics/blob/main/results/create%20table%20execution%20result.png)

### **Import CSV files into tables:**

```SQL
COPY app_events FROM 'E:\PostgreSQL\Mobile data\app_events.csv' DELIMITER ',' CSV HEADER; 
COPY app_labels FROM 'E:\PostgreSQL\Mobile data\app_labels.csv' DELIMITER ',' CSV HEADER;
COPY events FROM 'E:\PostgreSQL\Mobile data\events.csv' DELIMITER ',' CSV HEADER;
COPY gender_age_train FROM 'E:\PostgreSQL\Mobile data\gender_age_train.csv' DELIMITER ',' CSV HEADER;
COPY label_categories FROM 'E:\PostgreSQL\Mobile data\label_categories.csv' DELIMITER ',' CSV HEADER;
COPY phone_brand FROM 'E:\PostgreSQL\Mobile data\phone_brand_device_model.csv' DELIMITER ',' CSV HEADER;
```

### **An execution successful screenshot shown as below:**

![](https://github.com/BaomeiW/China-Mobile-User-Demographics-Data-Analytics/blob/main/results/import%20data%20execution%20result%20.png)

### **Design relational database with ERD shown as below:**

![](https://github.com/BaomeiW/China-Mobile-User-Demographics-Data-Analytics/blob/main/results/ER%20Diagram.png)

### **Check duplicated rows to make sure primary key has unique value, and preprocess data if necessary:**

```SQL
SELECT label_id, COUNT(*) From label_categories GROUP BY label_id HAVING COUNT(*) > 1;
SELECT event_id, COUNT(*) From events GROUP BY event_id HAVING COUNT(*) > 1;
SELECT device_id, COUNT(*) From phone_brand GROUP BY device_id HAVING COUNT(*) > 1;
SELECT APP_ID, COUNT (*) FROM APP_LABELS GROUP BY APP_ID HAVING COUNT (*) > 1;
```
### **There are 529 duplicated device_id in table phone_brand:**

![](https://github.com/BaomeiW/China-Mobile-User-Demographics-Data-Analytics/blob/main/results/device_id%20check.png)

### **There are 104786 duplicated app_id in table app_labels:**

![](https://github.com/BaomeiW/China-Mobile-User-Demographics-Data-Analytics/blob/main/results/app_id%20check.png)





