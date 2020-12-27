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
SELECT app_id, COUNT (*) FROM app_labels GROUP BY app_id HAVING COUNT (*) > 1;
```
### **There are 529 duplicated device_id in table phone_brand:**

![](https://github.com/BaomeiW/China-Mobile-User-Demographics-Data-Analytics/blob/main/results/device_id%20check.png)

### **Found two types of duplicates for device_id:**
#### 1. Values are same in all columns (523 records):

```SQL
SELECT device_id, phone_brand, device_model, COUNT(*) FROM phone_brand Group BY (device_id, phone_brand, device_model) HAVING COUNT(*) > 1 ORDER  BY device_id;
```
![](https://github.com/BaomeiW/China-Mobile-User-Demographics-Data-Analytics/blob/main/results/device_id%20duplicate%201.png)

#### 2. Values are same in device_id and phone_brand (6 records):

```SQL
SELECT * FROM (SELECT device_id, phone_brand, device_model,DENSE_RANK() OVER (PARTITION BY device_id ORDER BY (phone_brand, device_model)) From phone_brand) AS phone_brand1 WHERE DENSE_RANK > 1;
```
![](https://github.com/BaomeiW/China-Mobile-User-Demographics-Data-Analytics/blob/main/results/device_id%20duplicate%202.png)


### **There are 104786 duplicated app_id in table app_labels:**

```SQL
SELECT app_id, COUNT (*) FROM app_labels GROUP BY app_id HAVING COUNT (*) > 1;
```
![](https://github.com/BaomeiW/China-Mobile-User-Demographics-Data-Analytics/blob/main/results/app_id%20check.png) 

### **In the realistic data, device_id can only map one type of phone brand with certain model, also primary key can only be unique, so remove the duplicated records:**

```SQL
------ Delete duplicated rows using an immediate table ------

CREATE TABLE new_phone_brand (LIKE phone_brand);
INSERT INTO new_phone_brand(device_id, phone_brand, device_model)
SELECT DISTINCT ON (device_id) device_id, phone_brand, device_model FROM phone_brand;
SELECT device_id, COUNT(DISTINCT device_id) FROM new_phone_brand GROUP BY device_id;

CREATE TABLE new_app_labels (LIKE app_labels);
INSERT INTO new_app_labels (app_id, label_id)
SELECT DISTINCT ON (app_id) app_id, label_id FROM app_labels;
SELECT app_id, COUNT (DISTINCT app_id) FROM new_app_labels GROUP BY app_id;
```
### **Add primary key to existing tables:**

```SQL
ALTER TABLE new_phone_brand ADD PRIMARY KEY (device_id);
ALTER TABLE label_categories ADD PRIMARY KEY (label_id);
ALTER TABLE events ADD PRIMARY KEY (event_id);
ALTER TABLE new_app_labels ADD PRIMARY KEY (app_id);
```

### **Explore tables (check user demographics such as gender, age, age_group in the training samples, etc.):**

```SQL
SELECT gender, COUNT(*) FROM gender_age_train GROUP BY gender;
SELECT age, COUNT(*) FROM gender_age_train GROUP BY age ORDER BY COUNT(*) DESC;
SELECT age_group, COUNT(*) FROM gender_age_train GROUP BY age_group ORDER BY age_group, COUNT(*) DESC;
SELECT gender, age, age_group, COUNT(*) FROM gender_age_train GROUP BY gender, age, age_group ORDER BY gender, COUNT(*) DESC;
SELECT longitude,latitude, COUNT(*) FROM events GROUP BY (longitude, latitude) ORDER BY COUNT(*) DESC;
SELECT event_time, COUNT(*) FROM events GROUP BY event_time ORDER BY COUNT(*) DESC;
```

### **Most popular phone brands and device models:**

```SQL
SELECT phone_brand, COUNT(*) FROM new_phone_brand GROUP BY phone_brand ORDER BY COUNT(*) DESC LIMIT 10;

SELECT phone_brand, device_model, COUNT(*), ROW_NUMBER() OVER (PARTITION BY phone_brand ORDER BY COUNT(*) DESC) as rank FROM new_phone_brand 
WHERE phone_brand in (SELECT phone_brand FROM new_phone_brand GROUP BY phone_brand ORDER BY COUNT(*) DESC LIMIT 3)
GROUP BY phone_brand, device_model having count(*) > 700 ORDER BY phone_brand;
```
### **An execution successful screenshot shown as below:**

![](https://github.com/BaomeiW/China-Mobile-User-Demographics-Data-Analytics/blob/main/results/most%20popular%20brands.png)

### **Most popular phone brand and phone model for gender, age, and age group:**

```SQL
SELECT n.gender, n.phone_brand, COUNT(*),  ROW_NUMBER() OVER (PARTITION BY n.gender ORDER BY COUNT(*) DESC) AS row_num
FROM (SELECT gender_age_train.device_id, gender, age, age_group, phone_brand, device_model FROM gender_age_train
LEFT JOIN new_phone_brand ON gender_age_train.device_id = new_phone_brand.device_id) AS n
GROUP BY n.gender, n.phone_brand ORDER BY n.gender, COUNT(*) DESC
LIMIT 10;

CREATE VIEW phone_train AS 
SELECT gender_age_train.device_id, gender, age, age_group, phone_brand, device_model FROM gender_age_train
LEFT JOIN new_phone_brand ON gender_age_train.device_id = new_phone_brand.device_id

SELECT gender, phone_brand, COUNT(*), ROW_NUMBER() OVER (PARTITION BY gender ORDER BY COUNT(*) DESC) AS row_num_rank
FROM phone_train GROUP BY gender, phone_brand
ORDER BY gender, COUNT(*) DESC;

SELECT phone_brand, age_group, COUNT(*) as population_users, ROW_NUMBER() OVER (PARTITION BY phone_brand ORDER BY COUNT(*) DESC) AS rank
FROM phone_train WHERE phone_brand in (SELECT phone_brand FROM new_phone_brand GROUP BY phone_brand ORDER BY COUNT(*) DESC LIMIT 3)
GROUP BY phone_brand, age_group ORDER BY phone_brand DESC, COUNT(*) DESC;
```
### **An execution successful screenshot shown as below:**

![](https://github.com/BaomeiW/China-Mobile-User-Demographics-Data-Analytics/blob/main/results/most%20popular%20brand%20female%20group.png)

### **Favorite App**

```SQL
SELECT app_id, COUNT(*) FROM app_events
WHERE is_installed = '1' AND is_active = '1'
GROUP BY app_id ORDER BY COUNT(*) DESC;

SELECT app_events.app_id, a.category, COUNT(app_events.is_active) FROM app_events
JOIN (SELECT new_app_labels.app_id, label_categories.category FROM new_app_labels
LEFT JOIN label_categories ON new_app_labels.label_id = label_categories.label_id) AS a ON app_events.app_id = a.app_id
GROUP BY app_events.app_id, a.category ORDER BY COUNT(app_events.is_active) DESC
LIMIT 10;
```

![](https://github.com/BaomeiW/China-Mobile-User-Demographics-Data-Analytics/blob/main/results/favorite%20app.png)

### **Export result data to csv files and visualize the results by *tableau*:**

```SQL
COPY (SELECT gender, COUNT(*) FROM gender_age_train GROUP BY gender) TO 'E:\PostgreSQL\Mobile data\results\gender_ratio.csv' DELIMITER ',' CSV HEADER; 
COPY (SELECT age_group, COUNT(*) FROM gender_age_train GROUP BY age_group  
ORDER BY age_group, COUNT(*) DESC) TO 'E:\PostgreSQL\Mobile data\results\age_group.csv' DELIMITER ',' CSV HEADER;

COPY (SELECT gender, phone_brand, COUNT(*), ROW_NUMBER() OVER (PARTITION BY gender ORDER BY COUNT(*) DESC) AS row_num_rank FROM phone_train GROUP BY gender, phone_brand
ORDER BY gender, COUNT(*) DESC) TO 'E:\PostgreSQL\Mobile data\results\gender_brand.csv' DELIMITER ',' CSV HEADER;

COPY (SELECT phone_brand, device_model, COUNT(*) FROM new_phone_brand GROUP BY phone_brand, device_model
ORDER BY COUNT(*) DESC, phone_brand LIMIT 100) TO 'E:\PostgreSQL\Mobile data\results\brand_model.csv' DELIMITER ',' CSV HEADER;

COPY (SELECT phone_brand, COUNT(*) FROM new_phone_brand GROUP BY phone_brand 
ORDER BY COUNT(*) DESC LIMIT 10) TO 'E:\PostgreSQL\Mobile data\results\brand.csv' DELIMITER ',' CSV HEADER;

COPY (SELECT age, COUNT(*) FROM gender_age_train GROUP BY age ORDER BY COUNT(*) DESC) TO 'E:\PostgreSQL\Mobile data\results\age.csv' DELIMITER ',' CSV HEADER;

COPY (SELECT phone_brand, age_group, COUNT(*) as population_users, ROW_NUMBER() OVER (PARTITION BY phone_brand ORDER BY COUNT(*) DESC) AS rank FROM phone_train WHERE phone_brand IN (SELECT phone_brand FROM new_phone_brand GROUP BY phone_brand ORDER BY COUNT(*) DESC LIMIT 10)
GROUP BY phone_brand, age_group ORDER BY phone_brand DESC, COUNT(*) DESC) TO 'E:\PostgreSQL\Mobile data\results\age_brand.csv' DELIMITER ',' CSV HEADER;

COPY (SELECT phone_brand, device_model, COUNT(*) AS num_users, ROW_NUMBER() OVER (PARTITION BY phone_brand ORDER BY COUNT(*) DESC) AS rank FROM new_phone_brand 
WHERE phone_brand in (SELECT phone_brand FROM new_phone_brand GROUP BY phone_brand ORDER BY COUNT(*) DESC LIMIT 3)
GROUP BY phone_brand, device_model HAVING COUNT(*) > 700
ORDER BY phone_brand) TO 'E:\PostgreSQL\Mobile data\results\brand_model.csv' DELIMITER ',' CSV HEADER;
```



