------ Drop tables if exists ------

DROP TABLE IF EXISTS app_events;

DROP TABLE IF EXISTS app_labels;

DROP TABLE IF EXISTS events;

DROP TABLE IF EXISTS gender_age_train;

DROP TABLE IF EXISTS label_categories;

DROP TABLE IF EXISTS phone_brand;

DROP TABLE IF EXISTS new_phone_brand;

------ Create tables to get ready for importing data ------

CREATE TABLE app_events(event_id BIGINT, app_id BIGINT, is_installed VARCHAR, is_active VARCHAR);

CREATE TABLE app_labels(app_id BIGINT, label_id INTEGER);

CREATE TABLE events(event_id BIGINT, device_id BIGINT, event_time TIMESTAMP, longitude NUMERIC, latitude NUMERIC);

CREATE TABLE gender_age_train(device_id BIGINT, gender VARCHAR, age INTEGER, age_group VARCHAR);

CREATE TABLE label_categories(label_id INTEGER, category VARCHAR);

CREATE TABLE phone_brand(device_id BIGINT, phone_brand VARCHAR, device_model VARCHAR);
						 
------ Import csv file into tables ------

COPY app_events FROM 'E:\PostgreSQL\Mobile data\app_events.csv' DELIMITER ',' CSV HEADER;

COPY app_labels FROM 'E:\PostgreSQL\Mobile data\app_labels.csv' DELIMITER ',' CSV HEADER;

COPY events FROM 'E:\PostgreSQL\Mobile data\events.csv' DELIMITER ',' CSV HEADER;

COPY gender_age_train FROM 'E:\PostgreSQL\Mobile data\gender_age_train.csv' DELIMITER ',' CSV HEADER;

COPY label_categories FROM 'E:\PostgreSQL\Mobile data\label_categories.csv' DELIMITER ',' CSV HEADER;

COPY phone_brand FROM 'E:\PostgreSQL\Mobile data\phone_brand_device_model.csv' DELIMITER ',' CSV HEADER;

------ Check dupilcated records ------

SELECT device_id, COUNT(*) 
From phone_brand 
GROUP BY device_id HAVING COUNT(*) > 1;

SELECT label_id, COUNT(*) 
From label_categories 
GROUP BY label_id HAVING COUNT(*) > 1;

SELECT event_id, COUNT(*) 
From events GROUP BY event_id HAVING COUNT(*) > 1;

SELECT device_id, phone_brand, device_model, COUNT(*) 
FROM phone_brand
Group BY (device_id, phone_brand, device_model)
HAVING COUNT(*) > 1
ORDER  BY device_id;

SELECT * FROM (SELECT device_id, phone_brand, device_model,
               DENSE_RANK() OVER (PARTITION BY device_id ORDER BY (phone_brand, device_model))
From phone_brand) AS phone_brand1 WHERE DENSE_RANK > 1;

------ Delete duplicated rows using an immediate table ------

CREATE TABLE new_phone_brand (LIKE phone_brand);

INSERT INTO new_phone_brand(device_id, phone_brand, device_model)
SELECT DISTINCT ON (device_id) device_id, phone_brand, device_model FROM phone_brand;

SELECT device_id, COUNT(DISTINCT device_id) FROM new_phone_brand GROUP BY device_id;

------ Add primary key to existing tables ------

ALTER TABLE new_phone_brand ADD PRIMARY KEY (device_id);

ALTER TABLE label_categories ADD PRIMARY KEY (label_id);

ALTER TABLE events ADD PRIMARY KEY (event_id);

------ Explore tables (check user demographics such as gender, age, age_group in the training samples, etc.) ------

SELECT gender, COUNT(*) FROM gender_age_train GROUP BY gender;

SELECT age, COUNT(*) FROM gender_age_train GROUP BY age ORDER BY COUNT(*) DESC;

SELECT age_group, COUNT(*) FROM gender_age_train GROUP BY age_group ORDER BY age_group, COUNT(*) DESC;

SELECT gender, age, age_group, COUNT(*) FROM gender_age_train GROUP BY gender, age, age_group ORDER BY gender, COUNT(*) DESC;

SELECT longitude,latitude, COUNT(*) FROM events GROUP BY (longitude, latitude) ORDER BY COUNT(*) DESC;

SELECT event_time, COUNT(*) FROM events GROUP BY event_time ORDER BY COUNT(*) DESC;

------ Most popular phone brand and phone model ------

SELECT phone_brand, COUNT(*) FROM new_phone_brand GROUP BY phone_brand ORDER BY COUNT(*) DESC LIMIT 10;

SELECT phone_brand, device_model, COUNT(*),
ROW_NUMBER() OVER (PARTITION BY phone_brand ORDER BY COUNT(*) DESC) as rank
FROM new_phone_brand 
WHERE phone_brand in (SELECT phone_brand FROM new_phone_brand GROUP BY phone_brand ORDER BY COUNT(*) DESC LIMIT 3)
GROUP BY phone_brand, device_model
having count(*) > 700
ORDER BY phone_brand;

------ Most popular phone brand and phone model for gender, age, and age group ------

SELECT n.gender, n.phone_brand, COUNT(*), 
ROW_NUMBER() OVER (PARTITION BY n.gender ORDER BY COUNT(*) DESC) AS row_num
FROM (SELECT gender_age_train.device_id, gender, age, age_group, phone_brand, device_model FROM gender_age_train
LEFT JOIN new_phone_brand ON gender_age_train.device_id = new_phone_brand.device_id) AS n
GROUP BY n.gender, n.phone_brand
ORDER BY n.gender, COUNT(*) DESC
LIMIT 10;

CREATE VIEW phone_train AS 
SELECT gender_age_train.device_id, gender, age, age_group, phone_brand, device_model
FROM gender_age_train
LEFT JOIN new_phone_brand ON gender_age_train.device_id = new_phone_brand.device_id

SELECT gender, phone_brand, COUNT(*), 
ROW_NUMBER() OVER (PARTITION BY gender ORDER BY COUNT(*) DESC) AS row_num_rank
FROM phone_train GROUP BY gender, phone_brand
ORDER BY gender, COUNT(*) DESC;

SELECT phone_brand, age_group, COUNT(*) as population_users, 
ROW_NUMBER() OVER (PARTITION BY phone_brand ORDER BY COUNT(*) DESC) AS rank
FROM phone_train WHERE phone_brand in (SELECT phone_brand FROM new_phone_brand GROUP BY phone_brand ORDER BY COUNT(*) DESC LIMIT 3)
GROUP BY phone_brand, age_group
ORDER BY phone_brand DESC, COUNT(*) DESC; 

------ export result data to csv file and visualize the results by tableau ------

COPY (SELECT gender, COUNT(*) FROM gender_age_train GROUP BY gender) TO 'E:\PostgreSQL\Mobile data\results\gender_ratio.csv' DELIMITER ',' CSV HEADER; 

COPY (SELECT age_group, COUNT(*) FROM gender_age_train GROUP BY age_group  
ORDER BY age_group, COUNT(*) DESC) TO 'E:\PostgreSQL\Mobile data\results\age_group.csv' DELIMITER ',' CSV HEADER;

COPY (SELECT gender, phone_brand, COUNT(*), 
ROW_NUMBER() OVER (PARTITION BY gender ORDER BY COUNT(*) DESC) AS row_num_rank
FROM phone_train GROUP BY gender, phone_brand
ORDER BY gender, COUNT(*) DESC) TO 'E:\PostgreSQL\Mobile data\results\gender_brand.csv' DELIMITER ',' CSV HEADER;

COPY (SELECT phone_brand, device_model, COUNT(*) FROM new_phone_brand GROUP BY phone_brand, device_model
ORDER BY COUNT(*) DESC, phone_brand LIMIT 100) TO 'E:\PostgreSQL\Mobile data\results\brand_model.csv' DELIMITER ',' CSV HEADER;

COPY (SELECT phone_brand, COUNT(*) FROM new_phone_brand GROUP BY phone_brand 
ORDER BY COUNT(*) DESC LIMIT 10) TO 'E:\PostgreSQL\Mobile data\results\brand.csv' DELIMITER ',' CSV HEADER;

COPY (SELECT age, COUNT(*) FROM gender_age_train GROUP BY age ORDER BY COUNT(*) DESC) TO 'E:\PostgreSQL\Mobile data\results\age.csv' DELIMITER ',' CSV HEADER;

COPY (SELECT phone_brand, age_group, COUNT(*) as population_users, 
ROW_NUMBER() OVER (PARTITION BY phone_brand ORDER BY COUNT(*) DESC) AS rank
FROM phone_train WHERE phone_brand in (SELECT phone_brand FROM new_phone_brand GROUP BY phone_brand ORDER BY COUNT(*) DESC LIMIT 10)
GROUP BY phone_brand, age_group
ORDER BY phone_brand DESC, COUNT(*) DESC) TO 'E:\PostgreSQL\Mobile data\results\age_brand.csv' DELIMITER ',' CSV HEADER;


COPY (SELECT phone_brand, device_model, COUNT(*) AS num_users,
ROW_NUMBER() OVER (PARTITION BY phone_brand ORDER BY COUNT(*) DESC) as rank
FROM new_phone_brand 
WHERE phone_brand in (SELECT phone_brand FROM new_phone_brand GROUP BY phone_brand ORDER BY COUNT(*) DESC LIMIT 3)
GROUP BY phone_brand, device_model
having count(*) > 700
ORDER BY phone_brand) TO 'E:\PostgreSQL\Mobile data\results\brand_model.csv' DELIMITER ',' CSV HEADER;