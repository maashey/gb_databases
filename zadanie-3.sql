-- Создаём БД
CREATE DATABASE vk;

-- Делаем её текущей
USE vk;

/* 
 * 1.
 * Добавлен справочник стран - таблица countries, поле profiles.country заменено на profile.country_id
 * Добавлен справочник городов - таблица cities, поле profiles.citi заменено на profile.citi_id
 * Добавлен справочник статусов пользователей - таблица user_statuses, поле profiles.status заменено на profiles.status_id
 * Удалено поле messages.is_important 
 * Добавлено поле messages.is_read
 * Добавлено поле communities.is_moderated
 * 
 * 2.
 * Добавлены таблицы media_likes, posts, media_posts, posts_likes. 
 * По минимуму, так сказать. Была мысль создать таблицу лайков для медиа в рамках постов.
 * Ещё фотоальбомы можно допилить.
 * Не стала пока.
 * 
 * 3.
 * Дамп базы с тестовыми данными
 * 
 */


-- Создаём таблицу пользователей
CREATE TABLE users (
  	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
  	first_name VARCHAR(100) NOT NULL,
  	last_name VARCHAR(100) NOT NULL,
  	email VARCHAR(100) NOT NULL UNIQUE,
  	phone VARCHAR(100) NOT NULL,
  	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,  
  	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);  

-- Таблица профилей
CREATE TABLE profiles (
  	user_id INT UNSIGNED NOT NULL PRIMARY KEY, 
  	gender CHAR(1) NOT NULL,
  	birthday DATE,
  	avatar_id INT UNSIGNED COMMENT "Фото профиля из таблицы media",
  	status_id INT UNSIGNED COMMENT "Ссылка на user_statuses",
  	city_id INT UNSIGNED,
  	country_id INT UNSIGNED,
  	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,  
  	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
); 

-- Таблица стран
CREATE TABLE countries (
  	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
  	name VARCHAR(100) NOT NULL UNIQUE,
  	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,  
  	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Таблица городов
CREATE TABLE cities (
  	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
  	name VARCHAR(150) NOT NULL,
  	country_id INT UNSIGNED NOT NULL,
  	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,  
  	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Таблица статусов пользователей
CREATE TABLE user_statuses (
  	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
  	name VARCHAR(100) NOT NULL UNIQUE,
  	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,  
  	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Таблица сообщений
CREATE TABLE messages (
  	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
  	from_user_id INT UNSIGNED NOT NULL COMMENT "Ссылка на отправителя сообщения",
  	to_user_id INT UNSIGNED NOT NULL COMMENT "Ссылка на получателя сообщения",
  	body TEXT NOT NULL COMMENT "Текст сообщения",
  	is_read BOOLEAN COMMENT "Признак прочитанности",
  	is_delivered BOOLEAN COMMENT "Признак доставки",
  	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Таблица дружбы
CREATE TABLE friendship (
  	user_id INT UNSIGNED NOT NULL COMMENT "Ссылка на инициатора дружеских отношений",
  	friend_id INT UNSIGNED NOT NULL COMMENT "Ссылка на получателя приглашения дружить",
  	status_id INT UNSIGNED NOT NULL COMMENT "Ссылка на статус (текущее состояние) отношений",
  	requested_at DATETIME DEFAULT NOW() COMMENT "Время отправления приглашения дружить",
  	confirmed_at DATETIME COMMENT "Время подтверждения приглашения",
  	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,  
  	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,  
  	PRIMARY KEY (user_id, friend_id) COMMENT "Составной первичный ключ"
);

-- Таблица статусов дружеских отношений
CREATE TABLE friendship_statuses (
  	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  	name VARCHAR(150) NOT NULL UNIQUE,
  	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,  
  	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP  
);

-- Таблица групп
CREATE TABLE communities (
  	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  	name VARCHAR(150) NOT NULL UNIQUE,
  	is_moderated BOOLEAN NOT NULL DEFAULT FALSE COMMENT "Признак того, закрытая или открытая группа",
  	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,  
  	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP 
);

-- Таблица связей пользователей и групп
CREATE TABLE communities_users (
  	community_id INT UNSIGNED NOT NULL,
  	user_id INT UNSIGNED NOT NULL,
  	created_at DATETIME DEFAULT CURRENT_TIMESTAMP, 
  	PRIMARY KEY (community_id, user_id) COMMENT "Составной первичный ключ"
);

-- Таблица медиафайлов
CREATE TABLE media (
  	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  	user_id INT UNSIGNED NOT NULL COMMENT "Ссылка на пользователя, загрузившего файл",
  	filename VARCHAR(255) NOT NULL COMMENT "Путь к файлу",
  	filesize INT UNSIGNED NOT NULL COMMENT "Размер файла в байтах",
  	metadata JSON COMMENT "Метаданные файла",
  	media_type_id INT UNSIGNED NOT NULL COMMENT "Ссылка на тип контента",
  	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


-- Таблица типов медиафайлов
CREATE TABLE media_types (
  	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY ,
  	name VARCHAR(255) NOT NULL UNIQUE,
  	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,  
  	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Таблица лайков для медиафайлов пользователей (один медиафайл принадлежит только одному пользователю)
CREATE TABLE media_likes (
	media_id INT UNSIGNED NOT NULL,
	from_user_id INT UNSIGNED NOT NULL COMMENT "Кто лайкнул",
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (media_id, from_user_id) COMMENT "Составной первичный ключ"
);

-- Таблица постов
CREATE TABLE posts (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	user_id INT UNSIGNED NOT NULL,
	body TEXT NOT NULL,
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,  
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Таблица связи медиа и постов
CREATE TABLE media_posts (
	post_id INT UNSIGNED NOT NULL,
	media_id INT UNSIGNED NOT NULL,
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,  
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (post_id, media_id) COMMENT "Составной первичный ключ"
);

-- Таблица лайков для постов
CREATE TABLE posts_likes (
	post_id INT UNSIGNED NOT NULL,
	from_user_id INT UNSIGNED NOT NULL COMMENT "Кто лайкнул",
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (post_id, from_user_id) COMMENT "Составной первичный ключ"
);



