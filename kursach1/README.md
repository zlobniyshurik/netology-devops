Курсовая работа по итогам модуля "DevOps и системное администрирование"
=======================================================================

Пункт 1
-------

*Создайте виртуальную машину Linux.*

### Создание виртуалки
В наличии имеется хост на **Fedora35** с KVM-гипервизором и готовым шаблоном  
**Alma Linux 8.5** (немного перелицованный **CentOS 8.5** в минимальной установке)  
С ними и будем работать.  
  
+ На основе готового шаблона создаём клонированием виртуалку **Kursach**  
  
+ Через **nmtui** вбиваем статические IPv4/IPv6-адреса, адреса шлюза и DNS'а в сетевые настройки  
и там же меняем имя виртуалки на **kursach.experimental.mydomain.tld**  
*(имя специально взял подлиннее, чтобы не попадало в имена \*.mydomain.tld,  
на которые уже есть реальный сертификат от Let's Encrypt)*  
  
+ Перезапускаем систему через **reboot**  
  
+ Получаем примерно такую картинку:  
![Виртуалка](/kursach1/pic/k1_1.png)
  
+ Меняем пароль через **passwd**  
  
+ Не забываем сменить SSH-ключи на несовпадающие с шаблоном:  
```bash
rm -f /etc/ssh/ssh_host*
ssh-keygen -A
```
  
+ Всё, дальше уже можно с комфортом работать с виртуалкой через **SSH**  

Пункт 2
-------

*Установите* ***ufw*** *и разрешите к этой машине сессии на порты 22 и 443, при этом трафик на  
интерфейсе* ***localhost (lo)*** *должен ходить свободно на все порты.*  
  
### Анализ ситуации
  
Согласно экспертам, тип фаервола нам не важен - лишь бы нужные порты были открыты,  
а остальное надёжно защищено.  
  
У нас уже есть установленный по умолчанию **firewalld** - вот им и будем пользоваться.  
  
Смотрим текущую ситуацию через ```firewall-cmd --list-all-zones```:  
```bash
block
  target: %%REJECT%%
  icmp-block-inversion: no
  interfaces:
  sources:
  services:
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

dmz
  target: default
  icmp-block-inversion: no
  interfaces:
  sources:
  services: ssh
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

drop
  target: DROP
  icmp-block-inversion: no
  interfaces:
  sources:
  services:
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

external
  target: default
  icmp-block-inversion: no
  interfaces:
  sources:
  services: ssh
  ports:
  protocols:
  forward: no
  masquerade: yes
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

home (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.xxx.0/24 2001:470:xxx:yyy::0/64
  services: cockpit dhcpv6-client mdns samba-client ssh
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

internal
  target: default
  icmp-block-inversion: no
  interfaces:
  sources:
  services: cockpit dhcpv6-client mdns samba-client ssh
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

nm-shared
  target: ACCEPT
  icmp-block-inversion: no
  interfaces:
  sources:
  services: dhcp dns ssh
  ports:
  protocols: icmp ipv6-icmp
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
        rule priority="32767" reject

public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp1s0
  sources:
  services: cockpit dhcpv6-client ssh
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

trusted
  target: ACCEPT
  icmp-block-inversion: no
  interfaces:
  sources:
  services:
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

work
  target: default
  icmp-block-inversion: no
  interfaces:
  sources:
  services: cockpit dhcpv6-client ssh
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

Ситуация печальная - много лишних зон, да и открыто в них куча всего нам не нужного.  
  
### Наши хотелки
  
Хотелось бы ограничиться вообще двумя зонами:  
+ **work** - с разрешённым доступом через **SSH** с определённого IP (админская машина), здесь же разрешаем доступ  
к **HTTP/HTTPS** (админу тоже надо работать с будущим веб-сайтом)  
  
+ **public** - с открытыми портами **80** (для HTTP) и **443** (для HTTPS) для доступа к сайту с любых IP-адресов,  
стучащихся на сетевой интерфейс **enp1s0**  
  
### Исправляем настройки
  
К сожалению, зоны **block**, **drop** и **trusted** трогать нельзя - без них **firewalld** не стартует   
*(сам только что узнал)*
  
Для начала сносим built-in зоны с настройками по умолчанию, прописанные в xml-файлах, лежащих в **/usr/lib/firewalld/zones**  
Просто переименовываем эти файлы из **.xml** в **.xml_backup** (**block.xml**,**drop.xml** и **trusted.xml** не трогаем):  
```bash
cd /usr/lib/firewalld/zones
mv dmz.xml dmz.xml_backup
mv external.xml external.xml_backup
mv home.xml home.xml_backup
mv internal.xml internal.xml_backup
mv nm-shared.xml nm-shared.xml_backup
mv public.xml public.xml_backup
```
Аналогично поступаем с имеющимися пользовательскими настройками зон, лежащими в **/etc/firewalld/zones**,  
(но тут можно переименовывать всё подряд):  
```bash
cd /etc/firewalld/zones
rename .xml .xml_backup *
```
И, пока не перезапустили **firewalld**, оставшись без связи и настроек, срочно создаём зону **work**  
для доступа через **SSH, HTTP и HTTPS**, привязав её к админскому IP:  
![](/kursach1/pic/setup_work_zone.png)
  
Не забываем и про зону **public**, открыв порты для **HTTP(S)** и привязав зону к интерфейсу **enp1s0**:  
![](/kursach1/pic/setup_public_zone.png)
  
Перезагружаем фаервол:  
![](/kursach1/pic/k1_2_3.png)
  
### Результат доработок
  
В результате получаем значительно меньшее количество зон с минимально необходимым количеством правил,  
в чём можно удостовериться, посмотрев все имеющиеся настройки наших зон.  
  
Увидим примерно это:  
```bash
[root@kursach zones]# firewall-cmd --list-all-zones
block
  target: %%REJECT%%
  icmp-block-inversion: no
  interfaces: 
  sources: 
  services: 
  ports: 
  protocols: 
  forward: no
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 

drop
  target: DROP
  icmp-block-inversion: no
  interfaces: 
  sources: 
  services: 
  ports: 
  protocols: 
  forward: no
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules:

public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp1s0
  sources: 
  services: http https
  ports: 
  protocols: 
  forward: no
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 

trusted
  target: ACCEPT
  icmp-block-inversion: no
  interfaces: 
  sources: 
  services: 
  ports: 
  protocols: 
  forward: no
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 

work (active)
  target: default
  icmp-block-inversion: no
  interfaces: 
  sources: 192.168.xxx.yyy
  services: http https ssh
  ports: 
  protocols: 
  forward: no
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
```
  
И, как минимум, пробиться на **SSH** с других машин, кроме админской, уже не получается - видим примерно это:  
![](/kursach1/pic/k1_2_4.png)
  
### Выводы по настройке firewalld
  
Стоило ли возиться с **firewalld** вместо **ufw**?  
Уже не уверен, впрочем, новые знания получены, так что определённо оно того стоило...  

Задача 3
--------
*Установите* ***hashicorp vault***  
  
### Установка Hashicorp Vault
  
+ Ставим вспомогательную утилиту **yum-utils**:  
```bash
dnf install yum-utils
```
+ Подключаем репозиторий с Hashicorp Vault:  
```bash
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
```
+ Устанавливаем **hashicorp vault**:  
```bash
dnf install vault
```
+ Проверяем, что **vault** установился:  
![](/kursach1/pic/k1_3_1.png)
  
### Правка конфигов
  
+ Правим конфиг волта **etc/vault.d/vault.hcl** на работу через HTTP и с хранением информации на диске  
Внутри должно быть следующее:  
```bash
# Full configuration options can be found at https://www.vaultproject.io/docs/configuration

ui = false

#mlock = true
#disable_mlock = true

storage "file" {
  path = "/opt/vault/data"
}

# HTTP listener
listener "tcp" {
  address = "127.0.0.1:8200"
  tls_disable = 1
}

# HTTPS listener
#listener "tcp" {
#  address       = "127.0.0.1:8200"
#  tls_cert_file = "/opt/vault/tls/tls.crt"
#  tls_key_file  = "/opt/vault/tls/tls.key"
#}
```
  
### Запуск сервиса
  
+ Запускаем сервис волта:  
```bash
systemctl enable vault
systemctl start vault
```
  
+ Проверяем ещё раз волт на работоспособность через ```systemctl status vault```:  
Если все нормально, то сервис должен успешно запуститься без ошибок.  

Задача 4
--------
*Cоздайте центр сертификации по инструкции (ссылка) и выпустите сертификат для использования его  
в настройке веб-сервера* ***nginx*** *(срок жизни сертификата - месяц).*  
  
### Подготовка
  
+ Перво-наперво ставим вспомогательную утилиту **jq** для парсинга JSON-данных:  
```bash
dnf install jq
```
  
### Инициализация Vault-сервера
  
*Этот этап требуется один раз в жизни сервера с волтом*  
  
+ Заходим через SSH на второй экземпляр терминала нашей виртуалки  
  
+ Экспортируем переменную с адресом сервера нашего vault'а:  
```bash
export VAULT_ADDR=http://127.0.0.1:8200
```
  
+ Инициализируем волт:  
```bash
vault operator init
```
+ Увидим что-то вроде этого:  
![Vault Init](/kursach1/pic/vault_init.png)
  
+ Переписываем содержимое ключей в файлы **/vaultkeys/\*.key**  
  
+ Переписываем содержимое root-токена в файл **vaultkeys/root_token**  
  
+ Закрываем эту SSH-сессию - она нам больше не нужна  
  
### Разблокировка волта
  
+ Для разблокировки волта запускаем скрипт **vault_unseal.sh** со следующим содержимым:  
```bash
#!/usr/bin/env bash

#################################################################
# Разлочиваем хранилище содержимым первых трех файлов с ключами #
#                                                               #
# Ключи лежат в файлах vaultkeys/*.key                          #
#################################################################

#задаём метод доступа и адрес волта
export VAULT_ADDR='http://127.0.0.1:8200'

#пытаемся разлочить волт первыми тремя ключами
vault operator unseal $(cat vaultkeys/1.key)
vault operator unseal $(cat vaultkeys/2.key)
vault operator unseal $(cat vaultkeys/3.key)
```
  
+ Заодно логинимся под рутом, запустив скрипт **vault_login.sh** со следующим содержимым:  
```bash
#!/usr/bin/env bash

############################################
# Логинимся в волт под рутом.              #
#                                          #
#Токен берём из файла vaultkeys/root_token #
############################################

#задаём метод доступа и адрес волта
export VAULT_ADDR='http://127.0.0.1:8200'

#собственно, логинимся
vault login $(cat vaultkeys/root_token)
```
  
### Генерируем корневой сертификат
  
+ Запускаем скрипт генерации корневого сертификата, не забыв поправить имя домена:  
**gen_CA_cert.sh**  
```bash
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

#Конфигурируем пути для CA-сертификата и CRL (Certificate Revocation List)
vault write pki/config/urls issuing_certificates="$VAULT_ADDR/v1/pki/ca" crl_distribution_points="$VAULT_ADDR/v1/pki/crl"
```
  
+ Результат будет лежать в файле **certs/CA_cert.crt**
  
### Генерируем промежуточный сертификат
  
+ Запускаем скрипт генерации промежуточного сертификата, не забыв поправить имя домена:  
**gen_Int_cert.sh**  
```bash
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
```
  
+ Результат будет лежать в файле **certs/intermediate.cert.pem**
  
### Создаём роль
*Фактически мы создаём политику безопасности для конкретного домена и его поддоменов.*  
  
+ Запускаем скрипт генерации роли, не забыв поправить имя домена:  
**gen_role.sh**  
```bash
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
```
  
### Генерируем сертификат для конкретного домена
  
+ Запускаем скрипт генерации конечного сертификата, не забыв поправить имя домена и имя роли:  
**gen_cert.sh**  
```bash
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
```
  
Результат (ключи, сертификаты, серийники, даты) получим в папке **certs** в файлах **end\*.\***
  
Задача 5
--------
*Установите корневой сертификат созданного центра сертификации в доверенные в хостовой системе*  
  
+ Устанавливаем сертификат в доверенные:  
```bash
trust anchor path.to/certificate.crt
```
  
+ Проверяем, что сертификат установился через ```trust list```:
![Check CA_cert on host](/kursach1/pic/check_CA_cert_install.png)  
*Видим наш сертификат первым в списке*  
  
+ Когда сертификат будет не нужен, удалим его через ```trust anchor --remove path.to/certificate.crt```  

Задача 6
--------
*Установите* ***nginx***
  
### Установка nginx
  
+ Проверяем репозитории на доступность более-менее актуальной версии **nginx**'а:  
![check nginx repos](/kursach1/pic/module_list_nginx.png)
  
+ Ставим распоследнюю версию:  
```bash
dnf module install nginx:1.20
```
  
+ Запускаем сервис:  
```bash
systemctl enable nginx
systemctl start nginx
```
  
### Проверка на работоспособность
  
+ Проверяем сервис:  
```bash
systemctl status nginx
```
Получаем следующее:  
![check nginx service](/kursach1/pic/check_nginx_service.png)
  
+ Пытаемся зайти извне по HTTP:  
![check HTTP](/kursach1/pic/check_http.png)
*Как минимум, HTTP работает*  

Задача 7
--------
*настройте nginx на https, используя ранее подготовленный сертификат*  
  
### Создаём ключи Диффи-Хеллмана
  
+ Генерируем 4096-битные ключи Диффи-Хеллмана:  
```bash
openssl dhparam -out /etc/ssl/certs/dhparam.pem 4096
```
  
### Создаём веб-страничку
  
+ Создаём папку под наш мега-сайт:  
```bash
mkdir -p /var/www/html/kursach
```
  
+ Создаём в этой папке файл странички **index.html** с содержимым вроде этого:  
```html
<html>
    <head>
	<title>Kursach</title>
    </head>
    <body>
	<center><h1>!!!Kursach!!!</h1></center>
    </body>
</html>
```
  
+ Прописываем владельца **nginx:nginx** на наш каталог с сайтами:  
```bash
chown -R nginx:nginx /var/www
```
  
### Меняем конфиги nginx'а на работу с нашей страничкой через HTTPS
  
+ Конфиг **/etc/nginx/nginx.conf**:  
```nginx
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        return 301 https://$host$request_uri;
        #root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

}
```
  
+ Конфиг **/etc/nginx/conf.d/_default.conf** (не забываем поменять имя домена):  
```nginx
server {
        listen 443 ssl http2;

        server_name localhost kursach.experimental.mydomain.tld;

        #Задаем пути к файлам логов
        access_log /var/log/nginx/access.log main;
        error_log /var/log/nginx/error.log;

        ###########################
        # Настройки SSL для HTTPS #
        ###########################

        resolver 192.168.xxx.yyy;

        # Указываем пути к сертификатам
        ssl_certificate /etc/certs/kursach/fullchain.pem;
        ssl_certificate_key /etc/certs/kursach/privkey.pem;

        ssl_session_timeout 1d;
        ssl_session_cache shared:MozSSL:10m;  # about 40000 sessions
        ssl_session_tickets off;

        # 4096-битный ключ Диффи-Хеллмана
        ssl_dhparam /etc/pki/tls/certs/dhparam.pem;

        # Указываем виды шифрования (тут секьюрно, но без фанатизма)
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers on;

        ###########################
        # Усложняем жизнь хакерам #
        ###########################

        #Блокируем информацию по версии сервера
        server_tokens off;

        #Запрещаем отображение нашего сайта в фреймах
        add_header X-Frame-Options "SAMEORIGIN" always;

        # Трекинг с нашего сайта дальше нашего сайта не уйдёт
        add_header Referrer-Policy "strict-origin";

        #Чтобы браузеры не умничали сверх необходимого и не пытались найти, скажем, архив внутри картинки
        # Есть жёстко заданный MIME-тип - ему и следуем.
        add_header X-Content-Type-Options nosniff;

        #Content Security Policy - одна из самых мощных (и проблемных) настроек.
        #add_header Content-Security-Policy "default-src https: data: 'unsafe-inline' 'unsafe-eval'; object-src 'none';" always;
        add_header Content-Security-Policy "default-src https: data: ; object-src 'none';" always;

        #Указываем то, что наш сайт никогда использовать не будет
        add_header Permissions-Policy "geolocation=(), midi=(), notifications=(), push=(), sync-xhr=(), microphone=(), camera=(), magnetometer=(), gyroscope=(), speaker=(), vibrate=(), fullscreen=(), payment=();";

        #######################
        # Остальные настройки #
        #######################
        index index.html index.htm;

        ####################
        # Пути к каталогам #
        ####################

        #Путь к корневому каталогу по умолчанию
        root /usr/share/nginx/html;

        location / {
            root /var/www/html/kursach/;
            #try_files $uri $uri/ =404;
        }
}
```
  
### Подсовываем ключи и сертификаты
  
+ Копируем приватный ключ:  
```bash
cp path.to/private.key /etc/certs/kursach/privkey.pem
```
  
+ Создаём цепочку сертификатов:  
```bash
cat path.to/end_cert.crt > /etc/certs/kursach/fullchain.pem
cat path.to/end_ca_chain >> kursach/fullchain.pem
```
  
### Проверяем конфигурацию nginx
  
+ Проверяем конфигурацию через ```nginx -t```
  
### Перезапускаем nginx
  
+ Перезагружаем конфигурацию **nginx**'а:  
```bash
systemctl reload nginx
```
  
Задача 8
--------
*Откройте в браузере на хосте https адрес страницы, которую обслуживает сервер nginx.*  
  
+ Заходим с хост машины на наш сайт:  
Видим примерно это:  
![HTTPS](/kursach1/pic/https_demo.png)
  
В свойствах сертификата тоже явного криминала не видно:  
![Закладка1](/kursach1/pic/firefox_cert_info1.png)
  
![Закладка2](/kursach1/pic/firefox_cert_info2.png)
  
![Закладка3](/kursach1/pic/firefox_cert_info3.png)
  
Задача 9
--------
