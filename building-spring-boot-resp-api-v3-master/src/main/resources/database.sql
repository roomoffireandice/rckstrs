UPDATE DATABASE restapi;
USE restapi;
CREATE TABLE IF NOT EXISTS restapi.blog (
  id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
title VARCHAR(500)NOT NULL,
content VARCHAR(5000)NOT NULL
);

INSERT INTO restapi.blog (title,content) values("Message","Hello ​NodeJS ​World");