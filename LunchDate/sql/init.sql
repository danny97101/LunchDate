CREATE TABLE user (
	id int NOT NULL AUTO_INCREMENT,
	display_name varchar(255),
	username varchar(255) NOT NULL,
	password varchar(255) NOT NULL,
	salt varchar(255) NOT NULL,
	available_times varchar(255),
	last_updated datetime,
	PRIMARY KEY (id)
);

CREATE TABLE allergen (
	id int NOT NULL AUTO_INCREMENT,
	name varchar(255),
	PRIMARY KEY (id)
);

CREATE TABLE meal_option (
	id int NOT NULL AUTO_INCREMENT,
	dining_hall ENUM ('Towers', 'Terraces', 'Campus Center') NOT NULL,
	food_item varchar(255) NOT NULL,
	calories int,
	date_available date NOT NULL,
	PRIMARY KEY (id)
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
	PRIMARY KEY (id)
);

CREATE TABLE meal_option_to_allergen (
	id int NOT NULL AUTO_INCREMENT,
	meal_option_id int NOT NULL,
	allergen_id int NOT NULL,
	active tinyint DEFAULT 1,
	PRIMARY KEY (id)
);

CREATE TABLE user_to_date (
	id int NOT NULL AUTO_INCREMENT,
	user_id int NOT NULL,
	date_id int NOT NULL,
	active tinyint DEFAULT 1,
	PRIMARY KEY (id)
);