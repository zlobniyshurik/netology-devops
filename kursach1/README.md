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
  
+ Правим в **systemd** юнит волта, дабы каждый раз в скриптах не писать  
```export VAULT_ADDR=http://127.0.0.1:8200```:  
  
1. Открываем на редактирование unit-файл - ```systemctl edit vault --full```  
  
2. В секцию **[Service]** добавляем строчку ```PassEnvironment=VAULT_ADDR=http://127.0.0.1:8200```  
  
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
  
+ Перво-наперво ставим вспомогательную утилиту **jq**:  
```bash
dnf install jq
```
  
### Запуск Vault-сервера
  
+ Заходим через SSH на второй экземпляр терминала нашей виртуалки и запускаем там vault'овский  
dev-сервер с root'ом в качестве root-токена:  
```bash
vault server -dev -dev-root-token-id root
```
  
+ Возвращаемся к первому терминалу ssh и проверяем, что сервер **vault** работает:  
![](/kursach1/pic/k1_4_1.png)
  
+ Экспортируем переменную с адресом сервера нашего vault'а:  
```bash
export VAULT_ADDR=http://127.0.0.1:8200
```
  
+ Экспортируем переменную с токеном аутентификации:  
```bash
export VAULT_TOKEN=root
```
  
### Генерируем корневой сертификат
  
+ Запускаем **pki**-движок:  
```bash
vault secrets enable pki
```
  
+ выставляем срок жизни сертификатов в 10 лет:  
```bash
vault secrets tune -max-lease-ttl=87600h pki
```
  
+ Генерируем **root**-сертификат и сохраняем его в **CA_cert.crt**:  
```bash
vault write -field=certificate pki/root/generate/internal \
    common_name="experimental.mydomain.tld" \
    ttl=87600h > CA_cert.crt
```
  
+ Настраиваем URLы для CA и CRL:  
![](/kursach1/pic/k1_4_2.png)
  
### Генерируем промежуточный сертификат
  
+ Включаем **pki**-движок для **pki_int**:  
```bash
vault secrets enable -path=pki_int pki
```
  
+ Выставляем срок жизни промежуточных сертификатов в 5 лет:  
```bash
vault secrets tune -max-lease-ttl=43800h pki_int
```
  
+ Генерируем промежуточный сертификат и записываем Certificate Signing Request в **pki_intermediate.csr**:  
```bash
vault write -format=json pki_int/intermediate/generate/internal \
     common_name="experimental.mydomain.tld Intermediate Authority" \
     | jq -r '.data.csr' > pki_intermediate.csr
```
  
+ Подписываем промежуточный сертификат приватным ключом корневого сертификата и сохраняем  
результат в **intermediate.cert.pem**:  
```bash
vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr \
     format=pem_bundle ttl="43800h" \
     | jq -r '.data.certificate' > intermediate.cert.pem

```
  
+ После того, как Certificate Signing Request подписан и корневой центр авторизации вернул сертификат,  
его можно импортировать в **vault**:  
![](/kursach1/pic/k1_4_3.png)
  
### Создаём роли
  
+ Создаём роль **kursach**, которая разрешит поддомены и выставит срок жизни сертификата в месяц:  
```bash
vault write pki_int/roles/kursach \
    allowed_domains="experimental.mydomain.tld" \
    allow_subdomains=true \
    max_ttl="720h"
```
  
### Запрос сертификата
  
+ Запрашиваем сертификат на 1 месяц для **kursach.experimental.mydomain.tld**:  
```bash
vault write pki_int/issue/kursach common_name="kursach.experimental.mydomain.tld" ttl="720h" > certs
```
  
+ Итого, внутри файла **certs** у нас имеются:
*(Боевой ценности оно не имеет, можно и выложить)*
```bash
Key                 Value
---                 -----
ca_chain            [-----BEGIN CERTIFICATE-----
MIIDvjCCAqagAwIBAgIUZL8X7dW0RBOhRxVZPSnjy/VjJp8wDQYJKoZIhvcNAQEL
BQAwIjEgMB4GA1UEAxMXZXhwZXJpbWVudGFsLmJmZy0xMGsucnUwHhcNMjExMjEx
MDUxMTQ3WhcNMjYxMjEwMDUxMjE3WjA5MTcwNQYDVQQDEy5leHBlcmltZW50YWwu
YmZnLTEway5ydSBJbnRlcm1lZGlhdGUgQXV0aG9yaXR5MIIBIjANBgkqhkiG9w0B
AQEFAAOCAQ8AMIIBCgKCAQEAyqxnk7ul1uVW7I+2yPbMdQppJwIFDP+/4zZu1f3x
7cn46ahR0wH6y4gipKHWmacudAPHBKcUL2z4LbS8XCyKuBluBromGlWGIY8fWK9f
Tf4mRHjHtVwKkMuy55Ti8hFmBwmIwR3rXxJdHkn9Ulxs8ghAtiBQrGvW6L9CJ2Nz
6zxjaKHwGCCiSohUbBy1r9yCDQ3Istfhg3YpvM7v3OwJv1JONt+sx1ZR3x2PPSJ2
Y5zwALiTySt4AyyIyn3oe4ex6TmtOc1gAQKopzd1BiMcFzY5lGb6UaU4dda2IMs4
jiwPURZcp7T9Q1r367B/FmCJPJ9q00MSnODH36OEXoQTEwIDAQABo4HUMIHRMA4G
A1UdDwEB/wQEAwIBBjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBQsjUbPCL90
MbMm4mDkAa2r/02bPzAfBgNVHSMEGDAWgBQ6CmcqBRLRKuIvX6+rr0zIiU1PJDA7
BggrBgEFBQcBAQQvMC0wKwYIKwYBBQUHMAKGH2h0dHA6Ly8xMjcuMC4wLjE6ODIw
MC92MS9wa2kvY2EwMQYDVR0fBCowKDAmoCSgIoYgaHR0cDovLzEyNy4wLjAuMTo4
MjAwL3YxL3BraS9jcmwwDQYJKoZIhvcNAQELBQADggEBAAYV50CUF1b60aefrhWj
Hm8uT6lbC3rbK2vriqbyls7HA83i99jcMXms8QVe69g8WTvdZWClShcCUPVA1i6z
ObMXJTV3ygm3unPuDzU80H9ni4Wa3nTw56h/5ZSnRA9xAlKwRbvv1+UMQv14EBdR
ZhmuPsUs5oB/A4gS0BDQprJ7K4rQFUjftr4GrquRnVreR+Ud/5lYs4tdqHG5hYS+
GyKbAwKVoooAUn/7RN4kg8IILMVjVDrg1OcRYaqhZr5H9q3UxPFDc6TZje8prd3I
Y+LfMbAfrhonvb1uCllN31mhRMzLF22X6oYJoGUCElM29v6KYp1VjL6J0Am4VYhE
BUo=
-----END CERTIFICATE-----]
certificate         -----BEGIN CERTIFICATE-----
MIIDkDCCAnigAwIBAgIUf1zYSmT1SQM2IBppyANot6JvQ40wDQYJKoZIhvcNAQEL
BQAwOTE3MDUGA1UEAxMuZXhwZXJpbWVudGFsLmJmZy0xMGsucnUgSW50ZXJtZWRp
YXRlIEF1dGhvcml0eTAeFw0yMTEyMTEwNTU0NDBaFw0yMjAxMTAwNTU1MTBaMCox
KDAmBgNVBAMTH2t1cnNhY2guZXhwZXJpbWVudGFsLmJmZy0xMGsucnUwggEiMA0G
CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC1GLb5aSU4yOJbF3GmfFFfe+Voollp
eFWuRuVdq3RGLaxubJ3Bj/PDjNyLw97xb1rCQXpv1V6TPY90KIFLLgX+dk0HON36
igQ/JERyGzhGrVd0edCyHgokSDJO7J+DiRDh0v4w/YTF6Qgt4OEBXYCANr+rug8Q
tfg1PlIqXWxqkgsMSEwaO8alMgHYvMaQZ/B2h6qP+MXny/099OKv8ULh6UoGQHHE
7o+rlGpeOd0z3PMr9G+jFqMyKFARDyfqOXOXZ1DYB0UxV+25fg7WMEePD7dJhB/w
t/GAEM986RfGUXzJelHRnxrEIl3wtvNgHUXHgqJ3P1bjBWC9NuOBL0fJAgMBAAGj
gZ4wgZswDgYDVR0PAQH/BAQDAgOoMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEF
BQcDAjAdBgNVHQ4EFgQUCaY4wqfRJB2X6qfz49JVZFJ5LwcwHwYDVR0jBBgwFoAU
LI1Gzwi/dDGzJuJg5AGtq/9Nmz8wKgYDVR0RBCMwIYIfa3Vyc2FjaC5leHBlcmlt
ZW50YWwuYmZnLTEway5ydTANBgkqhkiG9w0BAQsFAAOCAQEAPbnPy8xfMhP/6PIM
ruryzgzYleNGJCAq0wFrNwqtSUSz6XvYMUnLUj88QZOmOKqlM2GJ4USf7xc751xp
mavU2G7Jvj8lk71gjX8SYp1orG9Zt28kqHHxUC4wV0UrpeQEEUOcfkcXFTg9099A
ZkVXNwsejjzwM6k2v0QGhZEQqLfS6jqLciWgXkSW2Hit3Tt+yem05Xyr//H+rhUB
EwZrdYJf1Wn9P08pwxmjylLYthCgaNC0TdYmf6EZj1oIDtqdgb4uoqETm2B4bK8z
LhlUfc7l55in7JRcmQY5HALjlcgjAfsfqydufw/5M81IH0of/U+aR9SnJLRwWyxi
AZXjtA==
-----END CERTIFICATE-----
expiration          1641794110
issuing_ca          -----BEGIN CERTIFICATE-----
MIIDvjCCAqagAwIBAgIUZL8X7dW0RBOhRxVZPSnjy/VjJp8wDQYJKoZIhvcNAQEL
BQAwIjEgMB4GA1UEAxMXZXhwZXJpbWVudGFsLmJmZy0xMGsucnUwHhcNMjExMjEx
MDUxMTQ3WhcNMjYxMjEwMDUxMjE3WjA5MTcwNQYDVQQDEy5leHBlcmltZW50YWwu
YmZnLTEway5ydSBJbnRlcm1lZGlhdGUgQXV0aG9yaXR5MIIBIjANBgkqhkiG9w0B
AQEFAAOCAQ8AMIIBCgKCAQEAyqxnk7ul1uVW7I+2yPbMdQppJwIFDP+/4zZu1f3x
7cn46ahR0wH6y4gipKHWmacudAPHBKcUL2z4LbS8XCyKuBluBromGlWGIY8fWK9f
Tf4mRHjHtVwKkMuy55Ti8hFmBwmIwR3rXxJdHkn9Ulxs8ghAtiBQrGvW6L9CJ2Nz
6zxjaKHwGCCiSohUbBy1r9yCDQ3Istfhg3YpvM7v3OwJv1JONt+sx1ZR3x2PPSJ2
Y5zwALiTySt4AyyIyn3oe4ex6TmtOc1gAQKopzd1BiMcFzY5lGb6UaU4dda2IMs4
jiwPURZcp7T9Q1r367B/FmCJPJ9q00MSnODH36OEXoQTEwIDAQABo4HUMIHRMA4G
A1UdDwEB/wQEAwIBBjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBQsjUbPCL90
MbMm4mDkAa2r/02bPzAfBgNVHSMEGDAWgBQ6CmcqBRLRKuIvX6+rr0zIiU1PJDA7
BggrBgEFBQcBAQQvMC0wKwYIKwYBBQUHMAKGH2h0dHA6Ly8xMjcuMC4wLjE6ODIw
MC92MS9wa2kvY2EwMQYDVR0fBCowKDAmoCSgIoYgaHR0cDovLzEyNy4wLjAuMTo4
MjAwL3YxL3BraS9jcmwwDQYJKoZIhvcNAQELBQADggEBAAYV50CUF1b60aefrhWj
Hm8uT6lbC3rbK2vriqbyls7HA83i99jcMXms8QVe69g8WTvdZWClShcCUPVA1i6z
ObMXJTV3ygm3unPuDzU80H9ni4Wa3nTw56h/5ZSnRA9xAlKwRbvv1+UMQv14EBdR
ZhmuPsUs5oB/A4gS0BDQprJ7K4rQFUjftr4GrquRnVreR+Ud/5lYs4tdqHG5hYS+
GyKbAwKVoooAUn/7RN4kg8IILMVjVDrg1OcRYaqhZr5H9q3UxPFDc6TZje8prd3I
Y+LfMbAfrhonvb1uCllN31mhRMzLF22X6oYJoGUCElM29v6KYp1VjL6J0Am4VYhE
BUo=
-----END CERTIFICATE-----
private_key         -----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAtRi2+WklOMjiWxdxpnxRX3vlaKJZaXhVrkblXat0Ri2sbmyd
wY/zw4zci8Pe8W9awkF6b9Vekz2PdCiBSy4F/nZNBzjd+ooEPyREchs4Rq1XdHnQ
sh4KJEgyTuyfg4kQ4dL+MP2ExekILeDhAV2AgDa/q7oPELX4NT5SKl1sapILDEhM
GjvGpTIB2LzGkGfwdoeqj/jF58v9PfTir/FC4elKBkBxxO6Pq5RqXjndM9zzK/Rv
oxajMihQEQ8n6jlzl2dQ2AdFMVftuX4O1jBHjw+3SYQf8LfxgBDPfOkXxlF8yXpR
0Z8axCJd8LbzYB1Fx4Kidz9W4wVgvTbjgS9HyQIDAQABAoIBAQCTfKNYENftnT0s
LrWyf0DOYNr/Eml7SjONkdOvK7mwhfYOoIsCXziJpCjh8w2Y17W0yxrqBX3WsKYq
Veqmzb639KTbIuc16j13JxRPUffNJ9M32xWqWmisD9hZCsEGoRSMtgeq4m3FuPme
U60sLXg/81a6hvdKBsk0o6LLOfbX+uV1EjvZqVGma12iYbttZZEA61FUoH9H/Ln5
CYul7ABlCiNbj2PoI4WXfccQrOz2WWPd76ZEuM6g3BM/A7/F8yZaNRhN2Mveixr8
uAox778VfbkqztaBmSpzc+04pomJKibs/YYhRDKirI5Xv+GjZsPJOjbgW0DymqqA
y9fISOLZAoGBAMoYbuJXcj79W5W0IR/uE/L2uAB57BbNTIkLAAiR6Zwr8AdKbxU1
hm+JOJUibtVVUOyzit5S3d4gYbDinchYBtHnr2VzXu9jXBLLDr5ftqhGkRC+RQ3z
U0kH+wHkOl5Hm0d8PL+n9AH+BxaSdSmyau7CmeSNoCnuS2qiiGO2MUx/AoGBAOVm
bQBz8HhMigQ1HEe3+VjWpviVVfGbdj6/7tCfg33DpnlRRyIubWwG1KtZh8wetfQw
n38ph4AF276QPr+6x65ozWeYQsxHB3vZer6RWC/R4Ja2pMZ0dYzx1+OA2v5y2NtH
Sne9n9XeytvBh9YnBeLynatC/JLF/iGZnEK+lee3AoGBAJqCDZx8kLr5xuBwg/a+
dYAHAmxSyp4wPXh08YSb0cf1i6B3VvAXKP3zIlBar/PoM2OUbPJG1puxlB7BUzJN
ooEuqdldWFKbW1R+7Hm+AY8rzFLJtU/SHXWzZUNv8vQLuPrxUByTUqmHRnIKbQsA
/mImY7PqV25XYk9XjgD11UEPAoGASrmGoDMkDcvA2YYDZElFa+7gDPF4QW+GoQIc
ZNDRIFJvE+2p4jSFaD8BX5+WYKNQWe7MxbtdbBJ8diK+je3lxaZV4nzypWAty+YX
2aO2ujz/j5iHLC4bbIIK9QywSVpX0XXzh/W47w3XvqXX/aZQgJDPU05Kv/TGx2Mm
R4eVhRkCgYB3Mj0s9R0f0S9Gq4hig6vUUL7cCLYfHYv6fauPesROfVeQMrBd8GC8
WoGhLsvQXGDeaMUBfwcVxrWHhjwRoXFyqthpIifL+CQDyR3JiqBfBoc5HBp1L2Ps
CJUMGZ1QvfSjfnNxpNWVzqQbMShmIT7hFs42+bnTDGvZPaEAg1ILEw==
-----END RSA PRIVATE KEY-----
private_key_type    rsa
serial_number       7f:5c:d8:4a:64:f5:49:03:36:20:1a:69:c8:03:68:b7:a2:6f:43:8d
```
  
*(осталось сообразить что со всем этим добром делать)*  

Задача 5
--------
*Установите корневой сертификат созданного центра сертификации в доверенные в хостовой системе*  
