# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

*В этом задании вы потренируетесь в:*
- *установке elasticsearch*
- *первоначальном конфигурировании elastcisearch*
- *запуске elasticsearch в docker*

*Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):*

- *составьте Dockerfile-манифест для elasticsearch*  

**Примерно так** ([Папка с исходниками для сборки](./src)):
```yml
# С какого линукса дерём основной образ
FROM centos:7

# создаём группу/юзера elasticsearch:elasticsearch,
# Устанавливаем wget
# Создаём папки в /opt/ext_volume для подключаемого тома (там будут данные и логи)
# Устанавливаем Elasticsearch в /opt,
# Задаём владельца elasticsearch:elasticsearch для подпапок в /opt

RUN groupadd elasticsearch \
    && useradd -s /sbin/nologin -c "elasticsearch" -g elasticsearch elasticsearch \
    && yum -y install wget \
    && yum clean all \
    && mkdir -p /opt/ext_volume/logs \
    && mkdir -p /opt/ext_volume/data \
    && cd /opt \
    && wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.0.0-linux-x86_64.tar.gz \
    && tar -xzf elasticsearch-8.0.0-linux-x86_64.tar.gz \
    && rm -f /opt/*.tar.gz \
    && chown -R elasticsearch:elasticsearch /opt/*

# Задаем каталог, который будет жить во внешнем томе
VOLUME /opt/ext_volume

# Копируем конфиги с настройками Elasticsearch
COPY --chown=elasticsearch:elasticsearch ./MyEScfg /opt/elasticsearch-8.0.0/config

# ES использует порты 9200 для http(s) и 9300 для продвинутых клиентов
EXPOSE 9200
EXPOSE 9300

# Переключаемся на юзера elasticsearch (с root`ом ES не работает)
USER elasticsearch:elasticsearch

# Задаём переменные среды для ES
ENV ES_USER=elasticsearch ES_GROUP=elasticsearch

# Задаём рабочий каталог
WORKDIR /opt/elasticsearch-8.0.0/bin

# Запускаем Elasticsearch
ENTRYPOINT ./elasticsearch
```
- *соберите docker-образ и сделайте `push` в ваш docker.io репозиторий*  

**Собираем:**
```bash
docker build . -t centos7-elasticsearch8_0_0
```
**Логинимся:**
```bash
docker login
```
**Навешиваем тэг для репы в докерхабе:**
```bash
docker tag centos7-elasticsearch8_0_0:latest zlobniyshurik/netology-devops:dz6.5
```
**Заливаем на докерхаб:**
```bash
docker push zlobniyshurik/netology-devops:dz6.5
```
- *запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины*  

**Создаём том для данных и логов** (они должны пережить выключение/рестарт контейнера):
```bash
docker volume create es_volume
```
**Запускаем:**
```bash
docker run -d --mount source=es_volume,target=/opt/ext_volume --ulimit nofile=65535 -p=9200:9200 -p=9300:9300 centos7-elasticsearch8_0_0
```
**Видим что-то вроде...**
```
[shurik@juggernaut MyEScfg]$ docker ps --all
CONTAINER ID   IMAGE                               COMMAND                  CREATED          STATUS          PORTS                                                                                  NAMES
68cdb7196a2c   centos7-elasticsearch8_0_0:latest   "/bin/sh -c ./elasti…"   39 minutes ago   Up 39 minutes   0.0.0.0:9200->9200/tcp, :::9200->9200/tcp, 0.0.0.0:9300->9300/tcp, :::9300->9300/tcp   brave_lederberg
```
**Проверяем ответ:**
```bash
[shurik@juggernaut MyEScfg]$ curl -X GET http://localhost:9200
{
  "name" : "netology_test",
  "cluster_name" : "ES_cluster",
  "cluster_uuid" : "6zBI3A-ESkm5h91uazv77w",
  "version" : {
    "number" : "8.0.0",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "1b6a7ece17463df5ff54a3e1302d825889aa1161",
    "build_date" : "2022-02-03T16:47:57.507843096Z",
    "build_snapshot" : false,
    "lucene_version" : "9.0.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
[shurik@juggernaut MyEScfg]$ 
```

*Требования к `elasticsearch.yml`:*
- *данные `path` должны сохраняться в `/var/lib`*  

**Нет уж, нет уж, левый софт, да ещё и не через ```dnf/yum/rpm``` ставленный, я лучше в ```/opt``` закину, там же и внешний том примонтирую.  
...Если что, и вычищать проще.**

- *имя ноды должно быть `netology_test`*

*В ответе приведите:*
- *текст Dockerfile манифеста*
- *ссылку на образ в репозитории dockerhub*

**[Мой репозиторий](https://hub.docker.com/r/zlobniyshurik/netology-devops) на Докерхабе**
- *ответ `elasticsearch` на запрос пути `/` в json виде*


*Подсказки:*
- *возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum*
- *при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml*
- *при некоторых проблемах вам поможет docker директива ulimit*
- *elasticsearch в логах обычно описывает проблему и пути ее решения*

*Далее мы будем работать с данным экземпляром elasticsearch.*

## Задача 2

*В этом задании вы научитесь:*
- *создавать и удалять индексы*
- *изучать состояние кластера*
- *обосновывать причину деградации доступности данных*

*Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:*

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

**Создаём индексы:**
```bash
curl -X PUT http://localhost:9200/ind-1 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_replicas": 0,  "number_of_shards": 1 }}'
curl -X PUT http://localhost:9200/ind-2 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_replicas": 1,  "number_of_shards": 2 }}'
curl -X PUT http://localhost:9200/ind-3 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_replicas": 2,  "number_of_shards": 4 }}'
```

**Получаем в ответ:**
```json
{"acknowledged":true,"shards_acknowledged":true,"index":"ind-1"}{"acknowledged":true,"shards_acknowledged":true,"index":"ind-2"}{"acknowledged":true,"shards_acknowledged":true,"index":"ind-3"}
```
----
*Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.*

**Получаем список индексов:**
```
[shurik@juggernaut src]$ curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   ind-1 bCRWnd_gRjm1kyfKC8canw   1   0          0            0       225b           225b
yellow open   ind-3 myAikqdWQleQMoyk4Y0PjQ   4   2          0            0       900b           900b
yellow open   ind-2 oIFC80EqQd241irbbqW9Yg   2   1          0            0       450b           450b
[shurik@juggernaut src]$
```

**Статус 1го индекса:**
```
[shurik@juggernaut src]$ curl -X GET 'http://localhost:9200/_cluster/health/ind-1?pretty'
{
  "cluster_name" : "ES_cluster",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 1,
  "active_shards" : 1,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
[shurik@juggernaut src]$
```

**Статус 2го индекса:**
```
[shurik@juggernaut src]$ curl -X GET 'http://localhost:9200/_cluster/health/ind-2?pretty'
{
  "cluster_name" : "ES_cluster",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 2,
  "active_shards" : 2,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 2,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}
[shurik@juggernaut src]$
```

**Статус 3го индекса:**
```
[shurik@juggernaut src]$ curl -X GET 'http://localhost:9200/_cluster/health/ind-3?pretty'
{
  "cluster_name" : "ES_cluster",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 4,
  "active_shards" : 4,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 8,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}
[shurik@juggernaut src]$
```
----
*Получите состояние кластера `elasticsearch`, используя API.*

**Статус кластера:**
```
[shurik@juggernaut src]$ curl -X GET 'http://localhost:9200/_cluster/health/?pretty=true'
{
  "cluster_name" : "ES_cluster",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 8,
  "active_shards" : 8,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}
[shurik@juggernaut src]$
```
----
*Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?*

**Нода в кластере одна, а количество реплик у части шардов больше нуля и раскидывать их некуда - мало нод.**

----
*Удалите все индексы.*

**Удаляем:**
```bash
[shurik@juggernaut MyEScfg]$ curl -X DELETE 'http://localhost:9200/ind-1?pretty'
{
  "acknowledged" : true
}
[shurik@juggernaut MyEScfg]$ curl -X DELETE 'http://localhost:9200/ind-2?pretty'
{
  "acknowledged" : true
}
[shurik@juggernaut MyEScfg]$ curl -X DELETE 'http://localhost:9200/ind-3?pretty'
{
  "acknowledged" : true
}
[shurik@juggernaut MyEScfg]$
```

**Перепроверяем состояние кластера:**
```bash
[shurik@juggernaut MyEScfg]$ curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index uuid pri rep docs.count docs.deleted store.size pri.store.size
[shurik@juggernaut MyEScfg]$
```
----
**Важно**

*При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.*

## Задача 3

*В данном задании вы научитесь:*
- *создавать бэкапы данных*
- *восстанавливать индексы из бэкапов*

*Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.*

**Пересобрал образ с учётом создания каталога */opt/ext_volume/snapshots* под снапшоты,  
прописывания этого каталога в конфиг-файле для Elasticsearch`а и  
с отключенным GeoIP (он нам не нужен, а с бэкапами работать мешает)**  
[Папка с модифицированными исходниками для сборки](./src2)  

----

*Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.*

***Приведите в ответе** запрос API и результат вызова API для создания репозитория.*

**Регистрируем через API директорию *netology_backup*:**
```bash
[shurik@juggernaut src2]$ curl -X POST http://localhost:9200/_snapshot/netology_backup?pretty -H 'Content-Type: application/json' -d'{"type": "fs", "settings": { "location":"/opt/ext_volume/snapshots" }}'
{
  "acknowledged" : true
}
[shurik@juggernaut src2]$
```

----

*Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.*

**Создаём индекс ```test```**:
```bash
[shurik@juggernaut src2]$ curl -X PUT http://localhost:9200/test -H 'Content-Type: application/json' -d'{ "settings": { "number_of_replicas": 0, "number_of_shards": 1 }}'
{"acknowledged":true,"shards_acknowledged":true,"index":"test"}[shurik@juggernaut src2]$
```

**Смотрим список индексов**:
```bash
[shurik@juggernaut src2]$ curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test  8AUelgbETem8uCUkF5baXA   1   0          0            0       225b           225b
[shurik@juggernaut src2]$
```

----

*[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.*

***Приведите в ответе** список файлов в директории со `snapshot`ами.*

**Создаём снапшот**:
```bash
[shurik@juggernaut src2]$ curl -X PUT http://localhost:9200/_snapshot/netology_backup/elasticsearch?wait_for_completion=true
{"snapshot":{"snapshot":"elasticsearch","uuid":"s83fs4KlTnuuQqfjP6e59Q","repository":"netology_backup","version_id":8000099,"version":"8.0.0","indices":["test"],"data_streams":[],"include_global_state":true,"state":"SUCCESS","start_time":"2022-03-02T04:11:05.095Z","start_time_in_millis":1646194265095,"end_time":"2022-03-02T04:11:05.495Z","end_time_in_millis":1646194265495,"duration_in_millis":400,"failures":[],"shards":{"total":1,"failed":0,"successful":1},"feature_states":[]}}[shurik@juggernaut src2]$ 
```

**Смотрим список файлов в папке со снапшотами**:
```bash
[elasticsearch@edf63300fedb bin]$ ls -la /opt/ext_volume/snapshots/
total 36
drwxr-xr-x. 1 elasticsearch elasticsearch   176 Mar  2 04:11 .
drwxr-xr-x. 1 elasticsearch elasticsearch    34 Mar  2 03:56 ..
-rw-r--r--. 1 elasticsearch elasticsearch   589 Mar  2 04:11 index-0
-rw-r--r--. 1 elasticsearch elasticsearch     8 Mar  2 04:11 index.latest
drwxr-xr-x. 1 elasticsearch elasticsearch    44 Mar  2 04:11 indices
-rw-r--r--. 1 elasticsearch elasticsearch 17135 Mar  2 04:11 meta-s83fs4KlTnuuQqfjP6e59Q.dat
-rw-r--r--. 1 elasticsearch elasticsearch   308 Mar  2 04:11 snap-s83fs4KlTnuuQqfjP6e59Q.dat
[elasticsearch@edf63300fedb bin]$
```

----

*Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.*

**Удаляем индекс ```test```**:
```bash
[shurik@juggernaut src2]$ curl -X DELETE 'http://localhost:9200/test?pretty'
{
  "acknowledged" : true
}
[shurik@juggernaut src2]$
```

**Создаём индекс ```test-2```**:
```bash
[shurik@juggernaut src2]$ curl -X PUT http://localhost:9200/test-2 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_replicas": 0, "number_of_shards": 1 }}'
{"acknowledged":true,"shards_acknowledged":true,"index":"test-2"}[shurik@juggernaut src2]$
```

**Смотрим список индексов**:
```bash
[shurik@juggernaut src2]$ curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 oez0F7msTnydqE0UB5uMBw   1   0          0            0       225b           225b
[shurik@juggernaut src2]$
```

----

*[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. *

***Приведите в ответе** запрос к API восстановления и итоговый список индексов.*

**Восстанавливаем индексы из снапшота**:  
***(на этом месте пришлось в `elasticsearch.yml` ещё и строчку `action.destructive_requires_name: false` добавлять)***
```bash
[shurik@juggernaut src2]$ curl -X POST 'http://localhost:9200/.*/_close?pretty'
{
  "acknowledged" : true,
  "shards_acknowledged" : false,
  "indices" : { }
}
[shurik@juggernaut src2]$ curl -X POST 'http://localhost:9200/_snapshot/netology_backup/elasticsearch/_restore?wait_for_completion=true'
{"snapshot":{"snapshot":"elasticsearch","indices":["test"],"shards":{"total":1,"failed":0,"successful":1}}}[shurik@juggernaut src2]$
```

**Любуемся на список индексов**:
```bash
[shurik@juggernaut src2]$ curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 oez0F7msTnydqE0UB5uMBw   1   0          0            0       247b           247b
green  open   test   x77pFGEBQr6JLdh4Nu01YQ   1   0          0            0       225b           225b
[shurik@juggernaut src2]$
```

----

*Подсказки:*
- *возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`*

---

### Как cдавать задание

*Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.*

---
