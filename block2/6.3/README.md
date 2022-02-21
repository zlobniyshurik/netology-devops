# Домашнее задание к занятию "6.3. MySQL"

## Введение

*Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).*

## Задача 1

*Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.*
Создаём файл **docker-compose.yml**:
```yml
#На основе рекомендаций от фирменного MySQL
#Юзер MySQL`я: root
#в базу заходим через:
#mysql -h db -u root -p
version: "3.8"

services:

  db:
    image: mysql:8-oracle
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: mypassword
    volumes:
      - db-volume:/var/lib/mysql

    ports:
      - 3306:3306

  adminer:
    image: adminer
    restart: always
    ports:
      - 8080:8080

volumes:
  db-volume:
```

Подымаем инстанс через 
```bash
docker-compose up
```

Заходим в MySQL и проверяем его работоспособность:
```
[shurik@juggernaut src]$ docker ps
CONTAINER ID   IMAGE            COMMAND                  CREATED          STATUS          PORTS                                                  NAMES
69b4e7b09f6a   adminer          "entrypoint.sh docke…"   31 minutes ago   Up 12 minutes   0.0.0.0:8080->8080/tcp, :::8080->8080/tcp              src_adminer_1
7a42e8a8ace7   mysql:8-oracle   "docker-entrypoint.s…"   31 minutes ago   Up 12 minutes   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 33060/tcp   src_db_1
[shurik@juggernaut src]$ docker exec -it 7a42e8a8ace7 mysql -h db -u root -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 8.0.28 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> quit
Bye
[shurik@juggernaut src]$
```
----

*Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него.*

Сливаем бэкап внутрь контейнера:
```bash
docker cp test_dump.sql 7a42e8a8ace7:/var/tmp/test_dump.sql
```

Создаём пустую базу данных, куда мы будем заливать бэкап:
```
[shurik@juggernaut src]$ docker exec -it 7a42e8a8ace7 mysql -h db -u root -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 10
Server version: 8.0.28 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> CREATE DATABASE testdb;
Query OK, 1 row affected (0.16 sec)

mysql> \q
Bye
[shurik@juggernaut src]$
```

Заливаем SQL-дамп в свежесозданную DB:
```
[shurik@juggernaut src]$ docker exec -it 7a42e8a8ace7 bash
bash-4.4#mysql -h db -u root -p testdb < /var/tmp/test_dump.sql
Enter password:
```
----
*Перейдите в управляющую консоль `mysql` внутри контейнера.*
```
bash-4.4# mysql -h db -u root -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 12
Server version: 8.0.28 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```
----
*Используя команду `\h` получите список управляющих команд.*
```
mysql> \h

For information about MySQL products and services, visit:
   http://www.mysql.com/
For developer information, including the MySQL Reference Manual, visit:
   http://dev.mysql.com/
To buy MySQL Enterprise support, training, or other products, visit:
   https://shop.mysql.com/

List of all MySQL commands:
Note that all text commands must be first on line and end with ';'
?         (\?) Synonym for `help'.
clear     (\c) Clear the current input statement.
connect   (\r) Reconnect to the server. Optional arguments are db and host.
delimiter (\d) Set statement delimiter.
edit      (\e) Edit command with $EDITOR.
ego       (\G) Send command to mysql server, display result vertically.
exit      (\q) Exit mysql. Same as quit.
go        (\g) Send command to mysql server.
help      (\h) Display this help.
nopager   (\n) Disable pager, print to stdout.
notee     (\t) Don't write into outfile.
pager     (\P) Set PAGER [to_pager]. Print the query results via PAGER.
print     (\p) Print current command.
prompt    (\R) Change your mysql prompt.
quit      (\q) Quit mysql.
rehash    (\#) Rebuild completion hash.
source    (\.) Execute an SQL script file. Takes a file name as an argument.
status    (\s) Get status information from the server.
system    (\!) Execute a system shell command.
tee       (\T) Set outfile [to_outfile]. Append everything into given outfile.
use       (\u) Use another database. Takes database name as argument.
charset   (\C) Switch to another charset. Might be needed for processing binlog with multi-byte charsets.
warnings  (\W) Show warnings after every statement.
nowarning (\w) Don't show warnings after every statement.
resetconnection(\x) Clean session context.
query_attributes Sets string parameters (name1 value1 name2 value2 ...) for the next query to pick up.

For server side help, type 'help contents'

mysql>
```
----
*Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.*
```
mysql> \s
--------------
mysql  Ver 8.0.28 for Linux on x86_64 (MySQL Community Server - GPL)
...
```
----
*Подключитесь к восстановленной БД и получите список таблиц из этой БД.*
```
mysql> USE testdb;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> SHOW TABLES;
+------------------+
| Tables_in_testdb |
+------------------+
| orders           |
+------------------+
1 row in set (0.00 sec)
```
----
***Приведите в ответе** количество записей с `price` > 300.*
```
mysql> SELECT COUNT(*) FROM orders WHERE price > 300;
+----------+
| COUNT(*) |
+----------+
|        1 |
+----------+
1 row in set (0.00 sec)
```

*В следующих заданиях мы будем продолжать работу с данным контейнером.*

## Задача 2

*Создайте пользователя test в БД c паролем test-pass, используя:*
- *плагин авторизации mysql_native_password*
- *срок истечения пароля - 180 дней*
- *количество попыток авторизации - 3*
- *максимальное количество запросов в час - 100*
- *аттрибуты пользователя:*
    - *Фамилия "Pretty"*
    - *Имя "James"*
```sql
mysql> CREATE USER 'test'@'localhost' IDENTIFIED WITH mysql_native_password BY 'test-pass'
    -> REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 100
    -> PASSWORD EXPIRE INTERVAL 180 DAY
    -> FAILED_LOGIN_ATTEMPTS 3
    -> ATTRIBUTE '{"fname": "James", "lname": "Pretty"}'
    -> ;
Query OK, 0 rows affected (0.11 sec)
```
----
*Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.*
```sql
mysql> GRANT SELECT ON testdb.* TO 'test'@'localhost';
Query OK, 0 rows affected, 1 warning (0.16 sec)
```
----    
*Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.*
```sql
mysql> SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE user='test';
+------+-----------+---------------------------------------+
| USER | HOST      | ATTRIBUTE                             |
+------+-----------+---------------------------------------+
| test | localhost | {"fname": "James", "lname": "Pretty"} |
+------+-----------+---------------------------------------+
1 row in set (0.00 sec)
```

## Задача 3

*Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.*

*Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.*

*Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:*
- *на `MyISAM`*
- *на `InnoDB`*

## Задача 4 

*Изучите файл `my.cnf` в директории /etc/mysql.*

*Измените его согласно ТЗ (движок InnoDB):*
- *Скорость IO важнее сохранности данных*
- *Нужна компрессия таблиц для экономии места на диске*
- *Размер буффера с незакомиченными транзакциями 1 Мб*
- *Буффер кеширования 30% от ОЗУ*
- *Размер файла логов операций 100 Мб*

*Приведите в ответе измененный файл `my.cnf`.*

---

### Как оформить ДЗ?

*Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.*

---
