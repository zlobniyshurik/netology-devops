#!/usr/bin/env bash

###################################
# Генерация корневого сертификата #
#                                 #
# Результат в certs/CA_cert.crt   #
###################################

#Имя домена
DOMAIN=mydomain.tld

#Максимальное время жизни корневого сертификата (ставим на 10 лет)
MAXTTL=87600h

#Время жизни нашего сертификата
TTL=87600h

#задаём метод доступа и адрес волта
export VAULT_ADDR='http://127.0.0.1:8200'

#Включаем pki движок
vault secrets enable pki

#Тюним максимальное время жизни корневого сертификата
vault secrets tune -max-lease-ttl=$MAXTTL pki

#Генерим корневой сертификат в certs/CA_cert.crt
vault write -field=certificate pki/root/generate/internal common_name=$DOMAIN ttl=$TTL > certs/CA_cert.crt
