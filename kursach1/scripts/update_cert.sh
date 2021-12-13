#!/usr/bin/env bash

##########################################
# Скрипт для автообновления сертификатов #
##########################################

#Распечатываем волт
echo "Vault unsealing..."
./vault_unseal.sh

#Логинимся в него под root`ом
echo "Login to vault..."
./vault_login.sh

#Генерим новый сертификат
echo "Create new certificate..."
./gen_cert.sh

#Запечатываем волт (кругом враги!)
echo "Vault sealing..."
./vault_seal.sh

#Копируем свежий приватный ключ в /etc/certs/kursach
echo "Private key copy..."
cp ./certs/end_private_key.pem /etc/certs/kursach/privkey.pem

#Создаём fullchain из нового сертификата и intermediate-сертификата в /etc/certs/kursach
echo "Fullchain copy..."
cat ./certs/end_cert.crt > /etc/certs/kursach/fullchain.pem
cat ./certs/end_ca_chain >> /etc/certs/kursach/fullchain.pem

#Перезагружаем конфиг nginx`а
echo "Nginx reloading"
systemctl reload nginx

