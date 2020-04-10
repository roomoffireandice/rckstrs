UPDATE DATABASE test;
USE test;
CREATE TABLE IF NOT EXISTS test.blog (
  id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
title VARCHAR(500)NOT NULL,
content VARCHAR(5000)NOT NULL
);

INSERT INTO test.blog (title,content) values("Message","HelloNodeJSWorld");

commit;

