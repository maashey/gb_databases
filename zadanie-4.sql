/*
 * В рамках 3го задания я сделала уже доработанну структуру.
 * Доработок столбцов в 4 задании у меня нет.
 * 
 * Данные в фейкере заполняла чуть более тщательно, 
 * проставляя подходящие диапазоны для случайных чисел, поэтому изменений в данных будет меньше, чем было на лекции.
 */

USE vk;

-- Дорабатываем тестовые данные
-- Смотрим все таблицы
SHOW TABLES;

-- Анализируем данные пользователей
SELECT * FROM users LIMIT 10;
-- Смотрим структуру таблицы пользователей
DESC users;
-- Приводим в порядок временные метки
UPDATE users SET updated_at = NOW() WHERE updated_at < created_at;
-- SELECT * FROM users WHERE UPDATED_AT>'2021-07-04 00:00:00';


-- Смотрим структуру профилей
DESC profiles;
-- Анализируем данные
SELECT * FROM profiles LIMIT 10;
-- Поправим столбец пола
CREATE TEMPORARY TABLE genders (name CHAR(1));
INSERT INTO genders VALUES ('m'), ('f');
SELECT * FROM genders;
-- Обновляем пол
UPDATE profiles 
  SET gender = (SELECT name FROM genders ORDER BY RAND() LIMIT 1);
 -- Пиводим в порядок временные метки т.к. пол обновился не во всех строках (в тестовых данных кое-где уже было 'm' и обновление на такое же значение не произошло)
UPDATE profiles SET updated_at = NOW() WHERE updated_at < created_at;


-- Смотрим структуру таблицы сообщений
DESC messages;
-- Анализируем данные
SELECT * FROM messages LIMIT 10;
SELECT * FROM messages WHERE FROM_USER_ID=TO_USER_ID;
-- Убираем сообщения "самому себе" (в вк кажется нет такой опции)
UPDATE messages SET 
  from_user_id = FLOOR(1 + RAND() * 100),
  to_user_id = FLOOR(1 + RAND() * 100)
WHERE FROM_USER_ID = TO_USER_ID ;
-- Приводим в порядок временные метки
UPDATE messages SET updated_at = NOW() WHERE updated_at < created_at;


-- Смотрим структуру таблицы медиаконтента 
DESC media;
-- Анализируем данные
SELECT * FROM media ORDER BY RAND() LIMIT 10;
-- Обновляем размер файлов
UPDATE media SET filesize = FLOOR(10000 + (RAND() * 1000000)) WHERE filesize>5000000;

SELECT * FROM media_types mt;
-- Добавляем нужные типы
INSERT INTO media_types (name) VALUES
  ('photo'),
  ('video'),
  ('audio'),
  ('document')
;
-- Обновляем данные для ссылки на тип 
UPDATE media SET media_type_id = FLOOR(1 + RAND() * 4);

DROP TEMPORARY TABLE extensions;
-- Создаём временную таблицу форматов медиафайлов
CREATE TEMPORARY TABLE extensions (name VARCHAR(10));
-- Заполняем значениями
INSERT INTO extensions VALUES ('jpeg'), ('avi'), ('mpeg'), ('png'), ('mp3'), ('gpx');
-- Проверяем
SELECT * FROM extensions;
-- Обновляем ссылку на файл
UPDATE media SET filename = CONCAT(
  'files/vk/',
  filename,
  (SELECT last_name FROM users ORDER BY RAND() LIMIT 1),
  '.',
  (SELECT name FROM extensions ORDER BY RAND() LIMIT 1)
);
-- Заполняем метаданные
UPDATE media SET metadata = CONCAT('{"owner":"', 
  (SELECT CONCAT(first_name, ' ', last_name) FROM users WHERE id = user_id),
  '"}');
-- Возвращаем столбцу метеданных правильный тип
ALTER TABLE media MODIFY COLUMN metadata JSON;



-- Смотрим структуру таблицы дружбы
DESC friendship;
RENAME TABLE friendship TO friendships;
-- Анализируем данные
SELECT * FROM friendships LIMIT 10;
-- Обновляем ссылки на друзей
UPDATE friendships SET 
  friend_id = FLOOR(1 + RAND() * 100);
SELECT count(*) FROM friendships;
SELECT count(*) FROM friendships WHERE user_id = friend_id;
-- Исправляем случай когда user_id = friend_id
UPDATE friendships SET friend_id = friend_id + 1 WHERE user_id = friend_id;
 
-- Анализируем данные 
SELECT * FROM friendship_statuses;
-- Очищаем таблицу
TRUNCATE friendship_statuses;
-- Вставляем значения статусов дружбы
INSERT INTO friendship_statuses (name) VALUES
  ('Requested'),
  ('Confirmed'),
  ('Rejected');
-- Обновляем ссылки на статус 
UPDATE friendships SET status_id = FLOOR(1 + RAND() * 3);
-- Приводим в порядок временные метки
UPDATE friendships SET updated_at = NOW() WHERE updated_at < created_at;


-- Смотрим структуру таблицы групп
DESC communities;
-- Анализируем данные
SELECT * FROM communities;
-- Приводим в порядок временные метки
UPDATE communities SET updated_at = NOW() WHERE updated_at < created_at;

-- Анализируем таблицу связи пользователей и групп
SELECT * FROM communities_users;
-- Добавляем значения в таблицу связей пользователей и групп
INSERT INTO communities_users (user_id, community_id)
VALUES (FLOOR(1 + RAND() * 100), FLOOR(1 + RAND() * 25));
SELECT COUNT(*) FROM communities_users;


DESC cities;
SELECT * FROM cities;
-- Приводим в порядок временные метки
UPDATE cities SET updated_at = NOW() WHERE updated_at < created_at;
-- Удаляем ссылку на страну из таблицы профилей потому что она уже есть в таблице cities
ALTER TABLE profiles DROP COLUMN country_id;

DESC countries;
SELECT * FROM countries;
-- Приводим в порядок временные метки
UPDATE countries SET updated_at = NOW() WHERE updated_at < created_at;

DESC posts;
SELECT * FROM posts LIMIT 10;
-- Приводим в порядок временные метки
UPDATE posts SET updated_at = NOW() WHERE updated_at < created_at;
SELECT COUNT(*) FROM posts;

DESC media_likes;
SELECT * FROM media_likes LIMIT 10;

DESC media_posts;
SELECT * FROM media_posts LIMIT 10;
-- Приводим в порядок временные метки
UPDATE media_posts SET updated_at = NOW() WHERE updated_at < created_at;

DESC posts_likes;
SELECT * FROM posts_likes;
UPDATE posts_likes SET from_user_id = FLOOR(1 + RAND() * 100);
