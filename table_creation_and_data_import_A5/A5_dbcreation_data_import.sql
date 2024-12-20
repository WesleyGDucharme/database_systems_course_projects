BEGIN TRANSACTION;

-- Table (topic_id, topic_date, topic)
CREATE TABLE topics (
  topic_id INT PRIMARY KEY,
  topic_date TIMESTAMP NOT NULL,
  topic_name TEXT NOT NULL UNIQUE
  
);

-- Table (category_id, category_name)
CREATE TABLE categories (
  category_id INT PRIMARY KEY,
  category_name TEXT NOT NULL UNIQUE
  
);

-- Table (user_id_author, username, email)
CREATE TABLE users_authors (
  user_id_author INT PRIMARY KEY,
  username TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE
  
);

-- Table (post_id, post_date, post, topic_id, category_id, user_id_author)
CREATE TABLE posts(
  post_id INT PRIMARY KEY,
  post_date TIMESTAMP NOT NULL,
  post TEXT NOT NULL UNIQUE,
  topic_id INT NOT NULL,
  FOREIGN KEY (topic_id) REFERENCES topics (topic_id) ON DELETE CASCADE,
  category_id INT NOT NULL,
  FOREIGN KEY (category_id) REFERENCES categories (category_id) ON DELETE CASCADE,
  user_id_author INT NOT NULL,
  FOREIGN KEY (user_id_author) REFERENCES users_authors (user_id_author) -- ON DELETE CASCADE ????
  
  );
  
-- Table (user_id_rating, post_id, rating)
CREATE TABLE ratings (
  user_id_rating INT NOT NULL,
  post_id INT NOT NULL,
  FOREIGN KEY (post_id) REFERENCES posts (post_id) ON DELETE CASCADE,
  rating INT NOT NULL CHECK(rating = 1 OR rating = -1),
  PRIMARY KEY(user_id_rating, post_id)
  
);
 
 COMMIT;
 
-- Question 6
BEGIN TRANSACTION;

-- Table that will get dropped at the end of the transaction.
CREATE TEMPORARY TABLE dump_to_import (
  post_id INT,
  topic_id INT,
  topic_date TIMESTAMP,
  post_date TIMESTAMP,
  topic TEXT,
  post TEXT,
  category_id INT,
  category TEXT,
  user_id_author INT,
  username TEXT,
  email TEXT,
  user_id_rating INT,
  rating INT
) ON COMMIT DROP;

-- Import data from the CSV into the temporary table.
copy dump_to_import
FROM 'C:\Users\Public\a5_dump.csv'
DELIMITER ',' 
CSV HEADER;

-- Import the CSV data into the topics table.
INSERT INTO topics (
  topic_id,
  topic_date,
  topic_name
)
SELECT
  topic_id,
  topic_date,
  "topic"
FROM dump_to_import
GROUP BY topic_id, topic_date, "topic";

-- Import the CSV data into the categories table.
INSERT INTO categories (
  category_id,
  category_name
)
SELECT
  category_id,
  "category"
FROM dump_to_import
GROUP BY category_id, "category";

-- Import the CSV data into the users_authors table.
INSERT INTO users_authors (
  user_id_author,
  username,
  email
)
SELECT
  user_id_author,
  "username",
  "email"
FROM dump_to_import
GROUP BY user_id_author, "username", "email";

-- Import the CSV data into the posts table.
INSERT INTO posts (
  post_id,
  post_date,
  post,
  topic_id,
  category_id,
  user_id_author
)
SELECT
  post_id,
  post_date,
  "post",
  topic_id,
  category_id,
  user_id_author
FROM dump_to_import
GROUP BY post_id, post_date, "post", topic_id, category_id, user_id_author;

-- Import the CSV data into the ratings table.
INSERT INTO ratings (
  user_id_rating,
  post_id,
  rating
)
SELECT
  user_id_rating,
  post_id,
  rating
FROM dump_to_import;

commit;