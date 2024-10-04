    CREATE DATABASE IF NOT EXISTS moviedbexample;
    USE moviedbexample;
    CREATE TABLE IF NOT EXISTS stars(
                   id varchar(10) primary key,
                   name varchar(100) not null,
                   birthYear integer
               );
    
    INSERT IGNORE INTO stars VALUES('755011', 'Arnold Schwarzeneggar', 1947);
    INSERT IGNORE INTO stars VALUES('755017', 'Eddie Murphy', 1961);
