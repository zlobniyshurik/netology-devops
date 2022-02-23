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

*Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).*

*Восстановите бэкап БД в `test_database`.*

*Перейдите в управляющую консоль `psql` внутри контейнера.*

*Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.*

*Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.*

***Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.*

## Задача 3

*Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).*

*Предложите SQL-транзакцию для проведения данной операции.*

*Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?*

## Задача 4

*Используя утилиту `pg_dump` создайте бекап БД `test_database`.*

*Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?*

---

### Как cдавать задание

*Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.*

---
