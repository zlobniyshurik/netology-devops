#!/usr/bin/env bash

########################################################
# Генерация промежуточного сертификата                 #
#                                                      #
# Результат будет лежать в certs/intermediate.cert.pem #
########################################################

#Домен, для которого генерируется промежуточный сертификат
DOMAIN=mydomain.tld

# Максимальное время жизни промежуточного сертификата (задаём 5 лет)
MAXTTL=43800h

# Время жизни промежуточного сертификата
TTL=43800h

# Задаём метод доступа и адрес волта
export VAULT_ADDR='http://127.0.0.1:8200'

# переходим в подкаталог certs для упрощения жизни
cd certs

# включаем PKI движок для pki_int пути
vault secrets enable -path=pki_int pki

# тюним движок под заданное максимальное время жизни промежуточных сертификатов
vault secrets tune -max-lease-ttl=$MAXTTL pki_int

# генерируем промежуточный сертификат и сохраняем Certificate Signing Request в cert/pki_intermediate.csr
vault write -format=json pki_int/intermediate/generate/internal common_name="$DOMAIN Intermediate Authority" | jq -r '.data.csr' > pki_intermediate.csr

# подписываем промежуточный сертификат приватным ключом root CA и записываем результат в cert/intermediate.cert.pem
vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr format=pem_bundle ttl=$TTL | jq -r '.data.certificate' > intermediate.cert.pem

# импортируем промежуточный сертификат обратно в волт
vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem
