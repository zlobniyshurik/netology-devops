# С какого линукса дерём основной образ
FROM centos:7

# создаём группу/юзера elasticsearch:elasticsearch,
# Устанавливаем wget и java-11
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