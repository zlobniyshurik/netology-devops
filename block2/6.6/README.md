# Домашнее задание к занятию "6.6. Troubleshooting"

## Задача 1

*Перед выполнением задания ознакомьтесь с документацией по [администрированию MongoDB](https://docs.mongodb.com/manual/administration/).*

*Пользователь (разработчик) написал в канал поддержки, что у него уже 3 минуты происходит CRUD операция в MongoDB и её 
нужно прервать.* 

***С MongoDB никогда не работал, ни в жизни, ни здесь - нам её не давали, поэтому могу и ошибаться...***

*Вы как инженер поддержки решили произвести данную операцию:*
- *напишите список операций, которые вы будете производить для остановки запроса пользователя*

0. Попытаюсь найти того, кто реально отвечает за **MongoDB** и, соответственно, эскалировать ситуацию на специально обученного человека.

1. Выясняю имя пользователя и базу.коллекцию, с которыми он работает.

2. Через `$currentOp` вычисляю `opid` затянувшегося запроса
```
use admin
db.aggregate( [
   { $currentOp : { allUsers: true, localOps: true } },
   { $match : {op:"query", "secs_running":{$gt:120}} }
] )
```

3. через `db.killOP()` убиваю подвисший запрос
```
db.killOp(<opid of the query to kill>)
```

- *предложите вариант решения проблемы с долгими (зависающими) запросами в MongoDB*

**Если верить документации, то можно добавлять поле `maxTimeMS` с указанием максимального времени операции.**  
**Примерно так:**
```
db.runCommand( { distinct: "collection",
                 key: "city",
                 maxTimeMS: 45 } )
```

## Задача 2

*Перед выполнением задания познакомьтесь с документацией по [Redis latency troobleshooting](https://redis.io/topics/latency).*

*Вы запустили инстанс Redis для использования совместно с сервисом, который использует механизм TTL. 
Причем отношение количества записанных key-value значений к количеству истёкших значений есть величина постоянная и
увеличивается пропорционально количеству реплик сервиса.* 

*При масштабировании сервиса до N реплик вы увидели, что:*
- *сначала рост отношения записанных значений к истекшим*
- *Redis блокирует операции записи*

*Как вы думаете, в чем может быть проблема?*

**Судя по симптомам, хранилище данных забито под завязку. И, возможно, мы просто не успеваем дожить до того момента, когда отжившие своё данные освободят место в базе.**

***Вообще, я с Redis`ом плотно не работал, поэтому могу не заметить очевидного.***  
**Но так или иначе:**
1. Читаем логи на предмет ошибок конфигурации и подсказок по их устранению.

2. Внимательно смотрим метрики.

3. Каков процент хранилища Redis'а свободен? Если места мало, то нельзя ли увеличить память, выделенную Redis`у под хранилище? Если можно, то изменится ли его поведение?

4. Нет ли свопинга памяти, выделенной Redis`у?

5. Нет ли запущенных медленных операций на Redis`е?

6. Действительно ли нам здесь должно хватать N реплик? Масштабирование далеко не всегда бывает линейным.

7. В конце-концов, не в Redis`е может быть дело - возможно нода, где крутится данный инстанс, содержит какое-то другое приложение, интенсивно пожирающее ресурсы. Соответственно, проверяем загрузку ноды.

**Но так-то, не имея под рукой конкретных метрик, достаточно сложно ставить диагноз по фотографии.**

## Задача 3

*Перед выполнением задания познакомьтесь с документацией по [Common Mysql errors](https://dev.mysql.com/doc/refman/8.0/en/common-errors.html).*

*Вы подняли базу данных MySQL для использования в гис-системе. При росте количества записей, в таблицах базы,
пользователи начали жаловаться на ошибки вида:*
```python
InterfaceError: (InterfaceError) 2013: Lost connection to MySQL server during query u'SELECT..... '
```

*Как вы думаете, почему это начало происходить и как локализовать проблему?*

*Какие пути решения данной проблемы вы можете предложить?*

**Если исключить проблемы с сетью, то вариантов остаётся немного:**  
1. Тайм-аут во время обработки запроса.  
Соответственно, надо увеличить допустимые тайм-ауты в настройках сервера - `net_read_timeout`, `connect_timeout`.  
Ну и посмотреть лог SLOW QUERY на предмет - что же там за запросы такие? Возможно, проблема не в сервере, а в криворуком пользователе, выкачивающем себе полную копию DB.

2. Идёт запрос слишком большого BLOB'а.  
То есть, надо увеличивать `max_allowed_packet`

**А вот что именно (`1` или `2`) произошло в нашем случае - надо смотреть в логе ошибок.**

## Задача 4

*Перед выполнением задания ознакомтесь со статьей [Common PostgreSQL errors](https://www.percona.com/blog/2020/06/05/10-common-postgresql-errors/) из блога Percona.*

*Вы решили перевести гис-систему из задачи 3 на PostgreSQL, так как прочитали в документации, что эта СУБД работает с 
большим объемом данных лучше, чем MySQL.*

*После запуска пользователи начали жаловаться, что СУБД время от времени становится недоступной. В dmesg вы видите, что:*

`postmaster invoked oom-killer`

*Как вы думаете, что происходит?*

***Всё потому, что кто-то слишком много ест!ⓒКролик из мультика про Винни-Пуха***

**Postgres'овский `postmaster` кушал слишком много памяти, за что и был зверски прибит `oom-killer`ом**

*Как бы вы решили данную проблему?*

**Гуру советуют выставить переменную ядра `vm.overcommit_memory` в значение, равное `2`. В этом случае ядро не будет резервировать больше памяти, чем указано в параметре `overcommit_ratio`**. 

**А в `overcommit_ratio` указывается максимальный процент процент памяти, для которого допустимо избыточное резервирование. Если для него нет места, память не выделяется, в резервировании будет отказано. Это самый безопасный вариант, рекомендованный для PostgreSQL.**

**Соответственно, при правильно подобранных настройках, программы будут получать разумные объёмы имеющейся памяти и `oom-killer`у вмешиваться почти не придётся.**

---

### Как cдавать задание

*Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.*

---