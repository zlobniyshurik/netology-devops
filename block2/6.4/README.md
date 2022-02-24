# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

*Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.*

**docker-compose.yml**:
```yml
#На основе рекомендаций от фирменного Postgres
#Юзер Postgres`а: postgres
version: "3.8"

services:

  db:
    image: postgres:13.6-alpine3.15
    restart: always
    environment:
      POSTGRES_PASSWORD: mypassword
    volumes:
      - db-volume:/var/lib/postgresql/data
    ports:
      - 5432:5432

  adminer:
    image: adminer
    restart: always
    ports:
      - 8080:8080

volumes:
  db-volume:
```
Запускаемся через ```docker-compose up``` и заходим в контейнер с **PostgreSQL**:
```
[shurik@juggernaut src]$ docker ps
CONTAINER ID   IMAGE                      COMMAND                  CREATED          STATUS          PORTS                                       NAMES
dec4ef9c6d8e   adminer                    "entrypoint.sh docke…"   26 seconds ago   Up 18 seconds   0.0.0.0:8080->8080/tcp, :::8080->8080/tcp   src_adminer_1
bf35fb0a19a0   postgres:13.6-alpine3.15   "docker-entrypoint.s…"   26 seconds ago   Up 19 seconds   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   src_db_1
[shurik@juggernaut src]$ docker exec -it bf35fb0a19a0 bash
bash-5.1#
```
----
*Подключитесь к БД PostgreSQL используя `psql`.*
```
bash-5.1# su - postgres
bf35fb0a19a0:~$ psql
psql (13.6)
Type "help" for help.

postgres=# 
```
----
*Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.*

***Найдите и приведите** управляющие команды для:*
- *вывода списка БД*  
```\l```
- *подключения к БД*  
```\c <имя_базы>```
- *вывода списка таблиц*  
```\dt```
- *вывода описания содержимого таблиц*  
```\d <имя_базы>```
- *выхода из psql*  
```\q```

## Задача 2

*Используя `psql` создайте БД `test_database`.*
```
postgres=# CREATE DATABASE test_database;
CREATE DATABASE
postgres=# \q
bf35fb0a19a0:~$
```
----
*Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).*

*Восстановите бэкап БД в `test_database`.*

Копируем SQL-дамп внутрь контейнера:
```bash
[shurik@juggernaut src]$ docker cp test_dump.sql bf35fb0a19a0:/var/tmp/test_dump.sql
[shurik@juggernaut src]$
```

В самом контейнере скармливаем дамп в ```psql```:
```bash
bf35fb0a19a0:~$ psql test_database < /var/tmp/test_dump.sql 
SET
SET
SET
SET
SET
 set_config 
------------
 
(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
COPY 8
 setval 
--------
      8
(1 row)

ALTER TABLE
bf35fb0a19a0:~$
```
----
*Перейдите в управляющую консоль `psql` внутри контейнера.*
```
bf35fb0a19a0:~$ psql
psql (13.6)
Type "help" for help.

postgres=# \l
                                   List of databases
     Name      |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
---------------+----------+----------+------------+------------+-----------------------
 postgres      | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0     | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
               |          |          |            |            | postgres=CTc/postgres
 template1     | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
               |          |          |            |            | postgres=CTc/postgres
 test_database | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
(4 rows)

postgres=#
```
----
*Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.*

```
postgres=# \c test_database
You are now connected to database "test_database" as user "postgres".
test_database=# \dt
         List of relations
 Schema |  Name  | Type  |  Owner   
--------+--------+-------+----------
 public | orders | table | postgres
(1 row)

test_database=# ANALYZE VERBOSE orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE
test_database=#
```
----
*Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.*

***Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.*

```sql
SELECT attname FROM pg_stats
  WHERE tablename='orders' AND avg_width = (
    SELECT MAX(avg_width) FROM pg_stats WHERE tablename='orders'
  );
```
Результат:
```
attname 
---------
 title
(1 row)

test_database=#
```

## Задача 3

*Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).*

*Предложите SQL-транзакцию для проведения данной операции.*

Как-то так:  
```sql
START TRANSACTION;
ALTER TABLE orders RENAME TO orders_old;
CREATE TABLE orders AS TABLE orders_old WITH NO DATA;
CREATE TABLE orders_1 () INHERITS (orders);
CREATE TABLE orders_2 () INHERITS (orders);
CREATE OR REPLACE FUNCTION orders_insert_trigger()
RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.price <= 499) THEN
    INSERT INTO orders_2 VALUES (NEW.*);
  ELSE INSERT INTO orders_1 VALUES (NEW.*);
  END IF;
  RETURN NULL;
END;
$$
LANGUAGE plpgsql;
CREATE TRIGGER insert_orders_trigger
  BEFORE INSERT ON orders
  FOR EACH ROW EXECUTE FUNCTION orders_insert_trigger();
INSERT INTO orders SELECT * FROM orders_old;
DROP TABLE orders_old;
COMMIT;
```
Интересно, это нормальный вариант или явный оверкилл?

Проверяем результат:
```sql
test_database=# SELECT * FROM orders_1;
 id |       title        | price 
----+--------------------+-------
  2 | My little database |   500
  6 | WAL never lies     |   900
  8 | Dbiezdmin          |   501
(3 rows)

test_database=# SELECT * FROM orders_2;
 id |        title         | price 
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
(5 rows)

test_database=# SELECT * FROM orders;
 id |        title         | price 
----+----------------------+-------
  2 | My little database   |   500
  6 | WAL never lies       |   900
  8 | Dbiezdmin            |   501
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
(8 rows)

test_database=#
```
----
*Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?*

Можно. Надо было немного подумать и написать что-то вроде:
```sql
CREATE TABLE orders (
    id integer,
    title character varying(80),
    price integer
)
PARTITION BY RANGE (price);
```
Ну и не забыть создать подтаблицы **orders_1** и **orders_2** с соответствующими диапазонами для ***price***.

## Задача 4

*Используя утилиту `pg_dump` создайте бекап БД `test_database`.*

*Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?*

---

### Как cдавать задание

*Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.*

---
