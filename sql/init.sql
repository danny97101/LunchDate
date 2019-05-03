CREATE TABLE user (
	id int NOT NULL AUTO_INCREMENT,
	display_name varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
	username varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL UNIQUE,
	password varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
	salt varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
	available_times varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
	last_updated datetime,
	token varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
	PRIMARY KEY (id)
);

CREATE TABLE user_to_user (
	id int NOT NULL AUTO_INCREMENT,
	user1_id int NOT NULL,
	user2_id int NOT NULL,
	status ENUM ('friends', 'requested', 'not friends') NOT NULL DEFAULT 'requested',
	PRIMARY KEY (id),
	UNIQUE(user1_id, user2_id)
);

CREATE TABLE allergen (
	id int NOT NULL AUTO_INCREMENT,
	name varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci UNIQUE,
	PRIMARY KEY (id)
);

CREATE TABLE meal_option (
	id int NOT NULL AUTO_INCREMENT,
	dining_hall ENUM ('Towers', 'Terraces', 'Campus Center') NOT NULL,
	food_item varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
	calories int,
	date_available date NOT NULL,
	PRIMARY KEY (id),
	UNIQUE(dining_hall, food_item, date_available)
);

CREATE TABLE date (
	id int NOT NULL AUTO_INCREMENT,
	date_date date NOT NULL,
	PRIMARY KEY (id)
);

CREATE TABLE user_to_allergen (
	id int NOT NULL AUTO_INCREMENT,
	user_id int NOT NULL,
	allergen_id int NOT NULL,
	active tinyint DEFAULT 1,
	PRIMARY KEY (id),
	UNIQUE(user_id, allergen_id)
);

CREATE TABLE meal_option_to_allergen (
	id int NOT NULL AUTO_INCREMENT,
	meal_option_id int NOT NULL,
	allergen_id int NOT NULL,
	active tinyint DEFAULT 1,
	PRIMARY KEY (id),
	UNIQUE(meal_option_id, allergen_id)
);

CREATE TABLE user_to_date (
	id int NOT NULL AUTO_INCREMENT,
	user_id int NOT NULL,
	date_id int NOT NULL,
	active tinyint DEFAULT 1,
	PRIMARY KEY (id),
	UNIQUE(user_id, date_id)
);