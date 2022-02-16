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

*Таблица clients*

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

*Используя SQL синтаксис:*
- *вычислите количество записей для каждой таблицы* 
- *приведите в ответе:*
    - *запросы* 
    - *результаты их выполнения.*

## Задача 4

*Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.*

*Используя foreign keys свяжите записи из таблиц, согласно таблице:*

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

*Приведите SQL-запросы для выполнения данных операций.*

*Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.*
 
*Подсказк - используйте директиву `UPDATE`.*

## Задача 5

*Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).*

*Приведите получившийся результат и объясните что значат полученные значения.*

## Задача 6

*Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).*

*Остановите контейнер с PostgreSQL (но не удаляйте volumes).*

*Поднимите новый пустой контейнер с PostgreSQL.*

*Восстановите БД test_db в новом контейнере.*

*Приведите список операций, который вы применяли для бэкапа данных и восстановления.* 

---

### Как cдавать задание

*Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.*

---
