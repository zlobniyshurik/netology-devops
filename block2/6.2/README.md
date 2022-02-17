# Домашнее задание к занятию "6.2. SQL"

## Введение

*Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).*

## Задача 1

*Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.*

*Приведите получившуюся команду или docker-compose манифест.*

**docker-compose манифест**:  
*(там ещё и **adminer**, ну да лишним не будет)*  
```yaml
#На основе рекомендаций от фирменного Postgres
#Юзер Postgres`а: postgres
version: "3.8"

services:

  db:
    image: postgres:12-alpine3.15
    restart: always
    environment:
      POSTGRES_PASSWORD: mypassword
    volumes:
      - db-volume:/var/lib/postgresql/data
      - backup-volume:/var/tmp
    ports:
      - 5432:5432

  adminer:
    image: adminer
    restart: always
    ports:
      - 8080:8080

volumes:
  db-volume:
  backup-volume:
```

Запускаем это чудо через 
```bash
docker-compose up
```

Залезаем в контейнер с PostgreSQL и запускаем **psql**
```bash
docker exec -it <container ID> sh
su - postgres
psql
```

Видим что-то в этом роде:
```
[shurik@juggernaut src]$ docker exec -it 73c526715be3 sh
/ # su - postgres
73c526715be3:~$ psql
psql (12.10)
Type "help" for help.

postgres=# 
```

## Задача 2

*В БД из задачи 1:* 
- *создайте пользователя test-admin-user и БД test_db*  
```sql
CREATE DATABASE test_db;
CREATE USER test_admin_user WITH PASSWORD 'admin_pass';
```
- *в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)*
```sql
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  наименование TEXT,
  цена INT
);

CREATE TABLE clients(
  id SERIAL PRIMARY KEY,
  фамилия TEXT,
  страна_проживания TEXT,
  заказ INT,
  CONSTRAINT fk_orders
    FOREIGN KEY (заказ)
    REFERENCES orders (id)
);

CREATE INDEX страна_проживания_idx ON clients(страна_проживания);
```
- *предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db*  
Не знаю, что за SEQUENCES такие, но гуру требуют давать разрешения и на эту штуку...
```sql
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO test_admin_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO test_admin_user;
```
- *создайте пользователя test-simple-user*
```sql
CREATE USER test_simple_user WITH PASSWORD 'simple_pass';
```  
- *предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db*  
А вот не-админа урежем до таблиц в схеме **public**
```sql
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO test_simple_user;
```

*Таблица orders:*
- *id (serial primary key)*
- *наименование (string)*
- *цена (integer)*

*Таблица clients:*
- *id (serial primary key)*
- *фамилия (string)*
- *страна проживания (string, index)*
- *заказ (foreign key orders)*

*Приведите:*
- *итоговый список БД после выполнения пунктов выше,*
```sql
test_db=# SELECT datname FROM pg_database;
  datname  
-----------
 postgres
 template1
 template0
 test_db
(4 rows)

test_db=#
```
- *описание таблиц (describe)*
```sql
test_db=# \d orders
                               Table "public.orders"
    Column    |  Type   | Collation | Nullable |              Default               
--------------+---------+-----------+----------+------------------------------------
 id           | integer |           | not null | nextval('orders_id_seq'::regclass)
 наименование | text    |           |          | 
 цена         | integer |           |          | 
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "fk_orders" FOREIGN KEY ("заказ") REFERENCES orders(id)

test_db=# \d clients
                                  Table "public.clients"
      Column       |  Type   | Collation | Nullable |               Default               
-------------------+---------+-----------+----------+-------------------------------------
 id                | integer |           | not null | nextval('clients_id_seq'::regclass)
 фамилия           | text    |           |          | 
 страна_проживания | text    |           |          | 
 заказ             | integer |           |          | 
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "страна_проживания_idx" btree ("страна_проживания")
Foreign-key constraints:
    "fk_orders" FOREIGN KEY ("заказ") REFERENCES orders(id)

test_db=#
```
- *SQL-запрос для выдачи списка пользователей с правами над таблицами test_db*
```sql
SELECT * from information_schema.table_privileges WHERE grantee LIKE 'test%';
```
- *список пользователей с правами над таблицами test_db*
```sql
test_db=# SELECT * from information_schema.table_privileges WHERE grantee LIKE 'test%';
 grantor  |     grantee      | table_catalog | table_schema | table_name | privilege_type | is_grantable | with_hierarchy 
----------+------------------+---------------+--------------+------------+----------------+--------------+----------------
 postgres | test_admin_user  | test_db       | public       | orders     | INSERT         | NO           | NO
 postgres | test_admin_user  | test_db       | public       | orders     | SELECT         | NO           | YES
 postgres | test_admin_user  | test_db       | public       | orders     | UPDATE         | NO           | NO
 postgres | test_admin_user  | test_db       | public       | orders     | DELETE         | NO           | NO
 postgres | test_admin_user  | test_db       | public       | orders     | TRUNCATE       | NO           | NO
 postgres | test_admin_user  | test_db       | public       | orders     | REFERENCES     | NO           | NO
 postgres | test_admin_user  | test_db       | public       | orders     | TRIGGER        | NO           | NO
 postgres | test_admin_user  | test_db       | public       | clients    | INSERT         | NO           | NO
 postgres | test_admin_user  | test_db       | public       | clients    | SELECT         | NO           | YES
 postgres | test_admin_user  | test_db       | public       | clients    | UPDATE         | NO           | NO
 postgres | test_admin_user  | test_db       | public       | clients    | DELETE         | NO           | NO
 postgres | test_admin_user  | test_db       | public       | clients    | TRUNCATE       | NO           | NO
 postgres | test_admin_user  | test_db       | public       | clients    | REFERENCES     | NO           | NO
 postgres | test_admin_user  | test_db       | public       | clients    | TRIGGER        | NO           | NO
 postgres | test_simple_user | test_db       | public       | orders     | INSERT         | NO           | NO
 postgres | test_simple_user | test_db       | public       | orders     | SELECT         | NO           | YES
 postgres | test_simple_user | test_db       | public       | orders     | UPDATE         | NO           | NO
 postgres | test_simple_user | test_db       | public       | orders     | DELETE         | NO           | NO
 postgres | test_simple_user | test_db       | public       | clients    | INSERT         | NO           | NO
 postgres | test_simple_user | test_db       | public       | clients    | SELECT         | NO           | YES
 postgres | test_simple_user | test_db       | public       | clients    | UPDATE         | NO           | NO
 postgres | test_simple_user | test_db       | public       | clients    | DELETE         | NO           | NO
(22 rows)

test_db=#
```

## Задача 3

*Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:*

*Таблица orders*

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Как-то так:  
```sql
INSERT INTO orders (наименование, цена)
  VALUES
  ('Шоколад', 10),
  ('Принтер', 3000),
  ('Книга',   500),
  ('Монитор', 7000),
  ('Гитара',  4000);
```

*Таблица clients*

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

И вот так:  
```sql
INSERT INTO clients (фамилия, страна_проживания)
  VALUES
  ('Иванов Иван Иванович', 'USA'),
  ('Петров Петр Петрович', 'Canada'),
  ('Иоганн Себастьян Бах', 'Japan'),
  ('Ронни Джеймс Дио', 'Russia'),
  ('Ritchie Blackmore', 'Russia');
```


*Используя SQL синтаксис:*
- *вычислите количество записей для каждой таблицы* 
- *приведите в ответе:*
    - *запросы* 
    - *результаты их выполнения.*

```sql
test_db=# SELECT COUNT(id) FROM orders;
 count 
-------
     5
(1 row)

test_db=# SELECT COUNT(id) FROM clients;
 count 
-------
     5
(1 row)

test_db=#
```

## Задача 4

*Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.*

*Используя foreign keys свяжите записи из таблиц, согласно таблице:*

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

*Приведите SQL-запросы для выполнения данных операций.*  
Примерно так:  
```sql
postgres=# \c test_db
You are now connected to database "test_db" as user "postgres".
test_db=# UPDATE clients SET заказ=3 WHERE id=1;
UPDATE 1
test_db=# UPDATE clients SET заказ=4 WHERE id=2;
UPDATE 1
test_db=# UPDATE clients SET заказ=5 WHERE id=3;
UPDATE 1
test_db=# 
```

*Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.*  
Сделано:  
```sql
test_db=# SELECT * FROM clients WHERE заказ IS NOT NULL;
 id |       фамилия        | страна_проживания | заказ 
----+----------------------+-------------------+-------
  1 | Иванов Иван Иванович | USA               |     3
  2 | Петров Петр Петрович | Canada            |     4
  3 | Иоганн Себастьян Бах | Japan             |     5
(3 rows)

test_db=#
```
 
*Подсказк - используйте директиву `UPDATE`.*

## Задача 5

*Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).*

*Приведите получившийся результат и объясните что значат полученные значения.*  
Результат получился следующим:
```sql
test_db=# EXPLAIN SELECT * FROM clients WHERE заказ IS NOT NULL;
                        QUERY PLAN                         
-----------------------------------------------------------
 Seq Scan on clients  (cost=0.00..18.10 rows=806 width=72)
   Filter: ("заказ" IS NOT NULL)
(2 rows)

test_db=#
```

В этом запросе планировщик выбрал план простого последовательного сканирования. Числа, перечисленные в скобках (слева направо), имеют следующий смысл:

* Приблизительная стоимость запуска **(0.00)**. Это время, которое проходит, прежде чем начнётся этап вывода данных, например для сортирующего узла это время сортировки.

* Приблизительная общая стоимость **(18.10)**. Она вычисляется в предположении, что узел плана выполняется до конца, то есть возвращает все доступные строки.

* Ожидаемое число строк **(806)**, которое должен вывести этот узел плана. При этом так же предполагается, что узел выполняется до конца.

* Ожидаемый средний размер строк **(72)**, выводимых этим узлом плана (в байтах).

Стоимость может измеряться в произвольных единицах, определяемых параметрами планировщика. Традиционно единицей стоимости считается операция чтения страницы с диска; то есть **seq_page_cost** обычно равен **1.0**, а другие параметры задаются относительно него.

## Задача 6

*Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).*

Бэкапим БД (правда, только содержимое, без юзеров):  
```bash
pg_dump -U postgres -h db -p 5432 --format=custom --clean --create --if-exists -f /var/tmp/test_db.custom test_db
```
**-U postgres** - имя пользователя

**-h db** - имя хоста

**-p 5432** - номер порта

**--format=custom** - формат бэкапа (его рекомендуют гуру)

**--clean** - предварительная зачистка восстанавливаемых объектов (вдруг в них что-то уже есть)

**--if-exists** - блокируем ругань при попытках зачистки несуществующих объектов

**-f /var/tmp/test_db.custom** - имя файла с бэкапом

**test_db** - имя забэкапливаемой базы

----

*Остановите контейнер с PostgreSQL (но не удаляйте volumes).*

 Убиваем контейнер с **PostgreSQL**.  
 **Adminer** можно было бы и не убивать, но свидетелей не оставляют.

```bash
[shurik@juggernaut src]$ docker ps
CONTAINER ID   IMAGE                    COMMAND                  CREATED        STATUS       PORTS                                       NAMES
162b7e0490d6   adminer                  "entrypoint.sh docke…"   19 hours ago   Up 2 hours   0.0.0.0:8080->8080/tcp, :::8080->8080/tcp   src_adminer_1
73c526715be3   postgres:12-alpine3.15   "docker-entrypoint.s…"   19 hours ago   Up 2 hours   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   src_db_1
[shurik@juggernaut src]$ docker stop 73c526715be3
73c526715be3
[shurik@juggernaut src]$ docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED        STATUS       PORTS                                       NAMES
162b7e0490d6   adminer   "entrypoint.sh docke…"   19 hours ago   Up 2 hours   0.0.0.0:8080->8080/tcp, :::8080->8080/tcp   src_adminer_1
[shurik@juggernaut src]$ docker stop 162b7e0490d6
162b7e0490d6
[shurik@juggernaut src]$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
[shurik@juggernaut src]$ docker rm 162b7e0490d6
162b7e0490d6
[shurik@juggernaut src]$ docker rm 73c526715be3
73c526715be3
```
Том с данными DB таки надо грохнуть.
```bash
[shurik@juggernaut src]$ docker volume ls
DRIVER    VOLUME NAME
local     src_backup-volume
local     src_db-volume
[shurik@juggernaut src]$ docker volume rm src_db-volume
src_db-volume
[shurik@juggernaut src]$ docker volume ls
DRIVER    VOLUME NAME
local     src_backup-volume
[shurik@juggernaut src]$
```

----

*Поднимите новый пустой контейнер с PostgreSQL.*

Перезапускаем контейнер с **PostgreSQL** через:  
```bash
docker-compose up
```

Заходим в контейнер:  
```bash
[shurik@juggernaut src]$ docker ps
CONTAINER ID   IMAGE                    COMMAND                  CREATED         STATUS         PORTS                                       NAMES
56caef5ecb15   adminer                  "entrypoint.sh docke…"   2 minutes ago   Up 2 minutes   0.0.0.0:8080->8080/tcp, :::8080->8080/tcp   src_adminer_1
129ff2b5a1c3   postgres:12-alpine3.15   "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   src_db_1
[shurik@juggernaut src]$ docker exec -it 129ff2b5a1c3 sh
/ # su - postgres
129ff2b5a1c3:~$
```

----

*Восстановите БД test_db в новом контейнере.*  
*Приведите список операций, который вы применяли для бэкапа данных и восстановления.*  

* Заходим в **psql**,
* проверяем что лишних баз нет,
* пересоздаём пользователей аналогично Задаче 2
* выходим из **psql**
```bash
129ff2b5a1c3:~$ psql
psql (12.10)
Type "help" for help.

postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(3 rows)

postgres=# CREATE USER test_admin_user WITH PASSWORD 'admin_pass';
CREATE ROLE
postgres=# CREATE USER test_simple_user WITH PASSWORD 'simple_pass';
CREATE ROLE
postgres=#\q
129ff2b5a1c3:~$
```

* Генерим скрипт восстановления через **pg_restore**
```bash
pg_restore --create --file=/var/tmp/pg_script /var/tmp/test_db.custom
```

* Скармливаем его в **psql**
```bash
psql -f /var/tmp/restore_script
```

* Заходим в **psql** и наслаждаемся видом восстановленной базы
```sql
129ff2b5a1c3:~$ psql
psql (12.10)
Type "help" for help.

postgres=# \l
                                    List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |      Access privileges       
-----------+----------+----------+------------+------------+------------------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                 +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                 +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =Tc/postgres                +
           |          |          |            |            | postgres=CTc/postgres       +
           |          |          |            |            | test_admin_user=CTc/postgres
(4 rows)

postgres=# 
postgres=# \c test_db
You are now connected to database "test_db" as user "postgres".
test_db=# SELECT * FROM clients;
 id |       фамилия        | страна_проживания | заказ 
----+----------------------+-------------------+-------
  4 | Ронни Джеймс Дио     | Russia            |      
  5 | Ritchie Blackmore    | Russia            |      
  1 | Иванов Иван Иванович | USA               |     3
  2 | Петров Петр Петрович | Canada            |     4
  3 | Иоганн Себастьян Бах | Japan             |     5
(5 rows)

test_db=# SELECT * FROM orders;
 id | наименование | цена 
----+--------------+------
  1 | Шоколад      |   10
  2 | Принтер      | 3000
  3 | Книга        |  500
  4 | Монитор      | 7000
  5 | Гитара       | 4000
(5 rows)

test_db=#
```

---

### Как cдавать задание

*Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.*

---
