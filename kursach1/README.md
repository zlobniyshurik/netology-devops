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
+ **work** - с разрешённым доступом через **SSH** с определённого IP (админская машина)  
  
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
для доступа через **SSH**, привязав её к админскому IP:  
![](/kursach1/pic/k1_2_1.png)
  
Не забываем и про зону **public**, открыв порты для **HTTP(S)** и привязав зону к интерфейсу **enp1s0**:  
![](/kursach1/pic/k1_2_2.png)
  
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
  services: ssh
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
  
###

Задача 5
--------
*Установите корневой сертификат созданного центра сертификации в доверенные в хостовой системе*  
