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

*Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.*

*Получите состояние кластера `elasticsearch`, используя API.*

*Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?*

*Удалите все индексы.*

**Важно**

*При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.*

## Задача 3

*В данном задании вы научитесь:*
- *создавать бэкапы данных*
- *восстанавливать индексы из бэкапов*

*Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.*

*Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.*

***Приведите в ответе** запрос API и результат вызова API для создания репозитория.*

*Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.*

*[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.*

***Приведите в ответе** список файлов в директории со `snapshot`ами.*

*Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.*

*[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. *

***Приведите в ответе** запрос к API восстановления и итоговый список индексов.*

*Подсказки:*
- *возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`*

---

### Как cдавать задание

*Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.*

---
