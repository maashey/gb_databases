-- ������� 1
-- ------------
-- [client]
-- user=root
-- password=mysql123


-- ������� 2
-- ------------
DROP DATABASE IF EXISTS example;
CREATE DATABASE example;
USE example;
 
CREATE TABLE IF NOT EXISTS users (
 	id SERIAL,
 	name VARCHAR(100) NOT NULL UNIQUE
 )
 
 DESCRIBE users;

 
 
 -- ������� 3
 -- ------------
 -- mysqldump example > example.sql
 CREATE DATABASE IF NOT EXISTS sample;
-- mysql sample < example.sql



 