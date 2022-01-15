Домашняя работа N11
===================

Задание 1
---------

*Работа c HTTP через телнет.*  
  
+ *Подключитесь утилитой телнет к сайту stackoverflow.com* ***telnet stackoverflow.com 80***  
+ *отправьте HTTP запрос*  

```bash
GET /questions HTTP/1.0
HOST: stackoverflow.com
[press enter]
[press enter]
```

+ *В ответе укажите полученный HTTP код, что он означает?*  
  
Вот что получили:  
![Ответ от stackoverflow.com](/dz11/pic/dz11_1.png)
  
Код 301 - "Перемещено навсегда", то есть, за актуальным содержимым сайта обращайтесь  
по адресу **https://stackoverflow.com/questions**  

Задание 2
---------

*Повторите задание 1 в браузере, используя консоль разработчика* ***F12.***  
+ *откройте вкладку* ***Network***  
+ *отправьте запрос* ***http://stackoverflow.com***  
+ *найдите первый ответ HTTP сервера, откройте вкладку* ***Headers***  
+ *укажите в ответе полученный HTTP код.*  
+ *проверьте время загрузки страницы, какой запрос обрабатывался дольше всего?*  
+ *приложите скриншот консоли браузера в ответ.*  
  
Если смотреть заголовки, то увидим **200 - Запрос выполнен успешно**:  
![Код 200](/dz11/pic/dz11_2_1.png)
  
Что касается времени, то дольше всего (375мс) грузился сам текст документа:  
![Загрузка с сайта](/dz11/pic/dz11_2_2.png)

Задание 3
---------

*Какой IP адрес у вас в интернете?*  
  
Часть ответа замазал внутренний безопасник:  
![Мой IP](/dz11/pic/dz11_3.png)

Задача 4
--------

*Какому провайдеру принадлежит ваш IP адрес? Какой автономной системе AS? Воспользуйтесь утилитой* ***whois***  
  
Как-то так:  
![Мой провайдер](/dz11/pic/dz11_4.png)

Задача 5
--------

*Через какие сети проходит пакет, отправленный с вашего компьютера на адрес* ***8.8.8.8*** *?  
Через какие AS? Воспользуйтесь утилитой* ***traceroute***  
  
**traceroute -A 8.8.8.8** выдал примерно следующее:  
```bash
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  _gateway (xxx.xxx.xxx.xxx) [*]  0.402 ms  0.528 ms  0.644 ms
 2  l37-194-xxx-xxx.novotelecom.ru (37.194.xxx.xxx) [AS31200]  1.817 ms  1.866 ms  1.891 ms
 3  10.245.138.241 (10.245.138.241) [*]  1.919 ms  1.951 ms  1.982 ms
 4  10.245.138.242 (10.245.138.242) [*]  2.225 ms  2.696 ms  2.255 ms
 5  l49-128-2.novotelecom.ru (178.49.128.2) [AS31200]  2.437 ms  2.482 ms  2.563 ms
 6  net131.234.188-158.ertelecom.ru (188.234.131.158) [AS9049]  44.667 ms  43.567 ms  43.321 ms
 7  net131.234.188-159.ertelecom.ru (188.234.131.159) [AS9049]  43.160 ms  43.365 ms 72.14.214.138 (72.14.214.138) [AS15169]  43.454 ms
 8  * * *
 9  209.85.240.254 (209.85.240.254) [AS15169]  44.031 ms 216.239.59.142 (216.239.59.142) [AS15169]  44.042 ms 209.85.245.238 (209.85.245.238) [AS15169]  44.251 ms
10  74.125.244.133 (74.125.244.133) [AS15169]  45.347 ms  45.424 ms 74.125.244.132 (74.125.244.132) [AS15169]  44.130 ms
11  72.14.232.84 (72.14.232.84) [AS15169]  45.655 ms  45.755 ms  45.667 ms
12  142.251.51.187 (142.251.51.187) [AS15169]  48.350 ms 172.253.64.113 (172.253.64.113) [AS15169]  48.699 ms 216.239.48.163 (216.239.48.163) [AS15169]  47.070 ms
13  172.253.51.247 (172.253.51.247) [AS15169]  47.925 ms * 142.250.210.47 (142.250.210.47) [AS15169]  47.672 ms
14  * * *
15  * * *
16  * * *
17  * * *
18  * * *
19  * * *
20  * * *
21  * * *
22  * dns.google (8.8.8.8) [AS15169]  47.522 ms  47.538 ms
```

Задача 6
--------

*Повторите задание 5 в утилите* ***mtr*** *. На каком участке наибольшая задержка - delay?*  
  
**mtr -z -c 5 -r 8.8.8.8** выдал следующее:  
```bash
[shurik@juggernaut netology-devops]$ mtr -z -c 5 -r 8.8.8.8
Start: 2021-11-26T10:58:14+0700
HOST: juggernaut.xxxxxxx.yy       Loss%   Snt   Last   Avg  Best  Wrst StDev
  1. AS???    _gateway             0.0%     5    0.4   0.4   0.4   0.4   0.0
  2. AS31200  l37-194-xxx-xxx.nov  0.0%     5    9.4   6.3   0.9  13.0   5.0
  3. AS???    10.245.138.241       0.0%     5    1.7   0.9   0.7   1.7   0.4
  4. AS???    10.245.138.242       0.0%     5    1.0   1.0   0.9   1.1   0.0
  5. AS31200  l49-128-2.novotelec  0.0%     5    1.3   3.4   1.1  12.1   4.9
  6. AS9049   net131.234.188-158.  0.0%     5   43.1  43.1  43.1  43.2   0.0
  7. AS15169  72.14.214.138        0.0%     5   43.1  43.0  42.9  43.1   0.1
  8. AS15169  74.125.244.129       0.0%     5   44.0  45.1  44.0  48.8   2.1
  9. AS15169  74.125.244.132       0.0%     5   42.7  47.1  42.7  57.7   6.6
 10. AS15169  216.239.48.163       0.0%     5   46.4  47.9  46.3  54.0   3.4
 11. AS15169  172.253.64.51        0.0%     5   48.5  48.7  48.2  49.8   0.6
 12. AS???    ???                 100.0     5    0.0   0.0   0.0   0.0   0.0
 13. AS???    ???                 100.0     5    0.0   0.0   0.0   0.0   0.0
 14. AS???    ???                 100.0     5    0.0   0.0   0.0   0.0   0.0
 15. AS???    ???                 100.0     5    0.0   0.0   0.0   0.0   0.0
 16. AS???    ???                 100.0     5    0.0   0.0   0.0   0.0   0.0
 17. AS???    ???                 100.0     5    0.0   0.0   0.0   0.0   0.0
 18. AS???    ???                 100.0     5    0.0   0.0   0.0   0.0   0.0
 19. AS???    ???                 100.0     5    0.0   0.0   0.0   0.0   0.0
 20. AS15169  dns.google          60.0%     5   46.2  46.3  46.2  46.5   0.1
```
  
Если ориентироваться на среднее значение задержки, то самый медленный 11ый хоп.

Задача 7
--------

*Какие DNS сервера отвечают за доменное имя* ***dns.google*** *? Какие A записи? воспользуйтесь утилитой* ***dig***  
  
Смотрим NS-сервера:  
```bash
[shurik@juggernaut netology-devops]$ dig -t ns dns.google

; <<>> DiG 9.16.23-RH <<>> -t ns dns.google
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 19329
;; flags: qr rd ra; QUERY: 1, ANSWER: 4, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;dns.google.                    IN      NS

;; ANSWER SECTION:
dns.google.             86400   IN      NS      ns1.zdns.google.
dns.google.             86400   IN      NS      ns2.zdns.google.
dns.google.             86400   IN      NS      ns3.zdns.google.
dns.google.             86400   IN      NS      ns4.zdns.google.

;; Query time: 653 msec
;; SERVER: 127.0.0.53#53(127.0.0.53)
;; WHEN: Fri Nov 26 11:16:43 +07 2021
;; MSG SIZE  rcvd: 116
```
  
Соответственно, нас интересуют NS-сервера:  
+ **ns1.zdns.google**  
+ **ns2.zdns.google**  
+ **ns3.zdns.google**  
+ **ns4.zdns.google**  
  
Далее смотрим A-записи:  
```bash
[shurik@juggernaut netology-devops]$ dig dns.google

; <<>> DiG 9.16.23-RH <<>> dns.google
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 29591
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;dns.google.                    IN      A

;; ANSWER SECTION:
dns.google.             3600    IN      A       8.8.8.8
dns.google.             3600    IN      A       8.8.4.4

;; Query time: 322 msec
;; SERVER: 127.0.0.53#53(127.0.0.53)
;; WHEN: Fri Nov 26 11:14:31 +07 2021
;; MSG SIZE  rcvd: 71
```
  
То есть, IP-адреса **8.8.8.8** и **8.8.4.4**  

Задача 8
--------

*Проверьте PTR записи для IP адресов из задания 7. Какое доменное имя привязано к IP? воспользуйтесь утилитой* ***dig***  
  
Проверяем **8.8.8.8**:  
```bash
[shurik@juggernaut netology-devops]$ dig -x 8.8.8.8

; <<>> DiG 9.16.23-RH <<>> -x 8.8.8.8
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 61255
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;8.8.8.8.in-addr.arpa.          IN      PTR

;; ANSWER SECTION:
8.8.8.8.in-addr.arpa.   30      IN      PTR     dns.google.

;; Query time: 0 msec
;; SERVER: 127.0.0.53#53(127.0.0.53)
;; WHEN: Fri Nov 26 12:22:22 +07 2021
;; MSG SIZE  rcvd: 73
```
Получаем **dns.google**  
  
Проверяем **8.8.4.4**:  
```bash
[shurik@juggernaut netology-devops]$ dig -x 8.8.4.4

; <<>> DiG 9.16.23-RH <<>> -x 8.8.4.4
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 6189
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;4.4.8.8.in-addr.arpa.          IN      PTR

;; ANSWER SECTION:
4.4.8.8.in-addr.arpa.   80528   IN      PTR     dns.google.

;; Query time: 45 msec
;; SERVER: 127.0.0.53#53(127.0.0.53)
;; WHEN: Fri Nov 26 12:22:37 +07 2021
;; MSG SIZE  rcvd: 73
```
Опять же получаем **dns.google**  
