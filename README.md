# README

## required pkg

```
fd-find ripgrep tomcat10 fzf fish mysql-server openjdk-11-jdk neovim
```

Q: There may be a issue with default java version

```
sudo update-alternatives --config java
```

it should give `/usr/lib/jvm/java-11-openjdk-amd64/bin/java` as one of the option

## mysql

1. login as root user via sudo

```sh
sudo mysql
```

2. add testuser

```mysql
CREATE USER 'mytestuser'@'localhost' IDENTIFIED BY '123123'; GRANT ALL PRIVILEGES ON *.* TO 'testuser'@'localhost' WITH GRANT OPTION;
```

SET GLOBAL general_log = 'ON';

3. log

```
log_error               /var/log/mysql/error.log
general_log_file        /var/lib/mysql/$hostname.log
slow_query_log_file     /var/lib/mysql/$hostname.log
datadir                 /var/lib/mysql/
```

4. log in as root user

`sudo -u root -p` can be replaced with `sudo mysql`

## tomcat10

- `tomcat10-admin` is required for management

## local development

- `maven`, but does not seem hard requirement

- Run intellij toolbox inside distrobox, so it can pickup jre and tomcat10
  - tomcat10 is at `/usr/share/tomcat10`
  - if log dir is missing at the begin, run `sudo mkdir -p /usr/share/tomcat10/logs/`
  - run `/usr/share/tomcat10/bin/startup.sh` to start, because systemctl does not work for dbx container
  - `server.xml` and `web.xml` are missing -> cp from `/etc/tomcat10` and `chmod o+r` them for intellij to copy
  - if firefox auto set it to https, website port 8080 does not work. Use http instead.

- `ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock' (2)`

  ```sh
  sudo service mysql --full-restart
  ```

## mysql

- run a script on a specific database

```sh
mysql database_name < script.sql
```

- run a command on a specific database

```sh
mysql moviedb -e "cmd"
```

```sh
mysql -e "USE database; cmd"
```
