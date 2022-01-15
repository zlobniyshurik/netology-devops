#!/usr/bin/env bash

#############################################
# Генерация сертификата под конкретный сайт #
#                                           #
# Результаты скидываются в папку certs      #
#############################################

# Имя домена
DOMAIN=mydomain.tld

# Имя роли
ROLENAME=mydomain_dot_tld

# Срок действия сертификата
TTL=720h

# Задаём метод доступа и адрес волта
export VAULT_ADDR='http://127.0.0.1:8200'

# Генерим сертификат и выдаём результат в JSON для дальнейшего парсинга
RESULT=$(vault write -format=json pki_int/issue/$ROLENAME common_name="$DOMAIN" ttl="$TTL")

# Извлекаем серийный номер сертификата и пишем его в certs/end_cert.sn
jq -r '.data.serial_number' <<< "$RESULT" > certs/end_cert.sn

# Извлекаем срок годности сертификата и пишем его в certs/end_cert_exp_date
EXPDATE=$(jq '.data.expiration' <<< "$RESULT")
# Пишем в юникс-формате
echo "Unix format: $EXPDATE" > certs/end_cert_exp_date
# Пишем в человекочитаемом виде
echo $(date -d @$EXPDATE) >> certs/end_cert_exp_date

# Выгрызаем сам сертификат и пишем его в certs/end_cert.crt
jq -r '.data.certificate' <<< "$RESULT" > certs/end_cert.crt

# Выгрызаем цепочку доверия и пишем её в certs/end_ca_chain
jq -r '.data.ca_chain[]' <<< "$RESULT" > certs/end_ca_chain

# Выгрызаем issuing_ca и пишем его в certs/end_issuing_ca.crt
jq -r '.data.issuing_ca' <<< "$RESULT" > certs/end_issuing_ca.crt

# Выгрызаем приватный ключ и пишем его в certs/end_private_key.pem
jq -r '.data.private_key' <<< "$RESULT" > certs/end_private_key.pem

# Выгрызаем тип приватного ключа и пишем его в certs/end_private_key_type
jq -r '.data.private_key_type' <<< "$RESULT" > certs/end_private_key_type
