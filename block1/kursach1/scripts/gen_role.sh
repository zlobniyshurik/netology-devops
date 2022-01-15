#!/usr/bin/env bash

###########################################
# Генерация ролей для домена и поддоменов #
###########################################

# Имя домена
DOMAIN=mydomain.tld

# Срок жизни сертификата (ставим в 1 месяц)
TTL=720h

# Задаём метод доступа и адрес волта
export VAULT_ADDR='http://127.0.0.1:8200'

# Заменяем в имени домена точки на _dot_ для получения имени роли
ROLENAME=${DOMAIN//./_dot_}

# И, чисто на всякий случай, записываем имя роли в папку rolenames,
# в файл с именем, совпадающим с именем обрабатываемого домена.
# Если что, всегда можно понять - какую роль к конкретному домену применять.
echo $ROLENAME > rolenames/$DOMAIN

# Собственно, создаём роль для домена со сроком жизни сертификата в месяц и разрешением на использование субдоменов
vault write pki_int/roles/$ROLENAME allowed_domains="$DOMAIN" allow_subdomains=true max_ttl="$TTL"
