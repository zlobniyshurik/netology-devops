Домашнее задание N14
====================

Задача 1
--------

*Установите* ***Bitwarden*** плагин для браузера. Зарегестрируйтесь и сохраните несколько паролей.*  
  
Сделано:  
![Bitwarden](/dz14/pic/dz14_1.png)
  
Но предпочитаю **keepass** - полный оффлайн и кроссплатформенность.  

Задача 2
--------
*Установите* ***Google authenticator*** *на мобильный телефон. Настройте вход в* ***Bitwarden*** *акаунт через* ***Google authenticator OTP*** *.*  
  
К сожалению, продемонстрировать решение этой задачи я не осилю по техническим причинам - как раз вчера  
мой смартфон уехал на длительный и дорогостоящий ремонт. Но так-то ничего сложного.  
  
Можно было бы в качестве второго фактора авторизации использовать почту, но игра не стоит свеч.  
Как правило, вводим мастер-пароль и смотрим почту с одной и той же машины, которая может быть уже скомпроментирована.  

Задача 3
--------
*Установите* ***apache2*** *, сгенерируйте самоподписанный сертификат, настройте тестовый сайт для работы по HTTPS.*  
  
Под боком уже была виртуалка с настроенным **nginx**'ом, поэтому всё делал там.  
  
Сгенерил сертификат:  
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/nginx-selfsigned.key -out /etc/ssl/nginx-selfsigned.crt
```
  
Скормил **nginx**'у немного урезанный относительно сайтов с нормальными сертификатами конфиг:  
```bash
server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;

        server_name testwww.local;

        #Задаем пути к файлам логов
        access_log /var/log/nginx/testwww.local/access.log main if=$loggable;
        error_log /var/log/nginx/testwww.local/error.log;

        ###########################
        # Настройки SSL для HTTPS #
        ###########################

        resolver 192.168.xxx.yyy [2001:470:xxxx:yyyy::zzzz];

        # Указываем пути к сертификатам

        ssl_certificate /etc/ssl/nginx-selfsigned.crt;

        ssl_certificate_key /etc/ssl/nginx-selfsigned.key;

        ssl_session_timeout 1d;
        ssl_session_cache shared:MozSSL:10m;  # about 40000 sessions
        ssl_session_tickets off;

        # 4096-битный ключ Диффи-Хеллмана
        ssl_dhparam /etc/pki/tls/certs/dhparam.pem;

        # Указываем виды шифрования (тут секьюрно, но без фанатизма)
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-
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
        add_header Permissions-Policy "geolocation=(), midi=(), notifications=(), push=(), sync-xhr=(), microphone=(), camera=(), magnetometer

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
            root /var/www/testwww.local/;
            #try_files $uri $uri/ =404;
        }

        #Статистика сервера - отдаём только локальным машинам
        location = /basic_status {
            stub_status;
            allow  192.168.xxx.0/24;
            allow  2001:470:xxxx:yyyy::0/64;
            deny all;
            access_log off;
        }

}
```
  
Итого получаем примерно следующее  
*(Firefox имел своё собственное мнение по поводу самоподписанных сертификатов)*:  
  
![Загрузка по HTTPS](/dz14/pic/dz14_3.png)
  
Остальные сайты давно получают сертификаты от **Let's Encrypt** и в ус не дуют...  

Задача 4
--------
*Проверьте на TLS уязвимости произвольный сайт в интернете.*  
  
Проверил один из подшефных сайтов **wiki.bfg-10k.ru**:  
<https://github.com/zlobniyshurik/netology-devops/tree/master/dz14/test.log>  
  
Итог: **враги не пройдут!**  

Задача 5
--------
*Установите на Ubuntu* ***ssh*** *сервер, сгенерируйте новый приватный ключ. Скопируйте свой публичный  
ключ на другой сервер. Подключитесь к серверу по SSH-ключу.*  
  
Генерим ключ:  
![Генерация SSH-ключа](/dz14/pic/dz14_5_1.png)
  
Подключаемся сами к себе:  
![Подключение через SSH](/dz14/pic/dz14_5_2.png)

Задача 6
--------


Задача 7
--------
*Соберите дамп трафика утилитой* ***tcpdump*** *в формате* ***pcap*** *, 100 пакетов. Откройте файл* ***pcap*** *в* ***Wireshark.***  
  
Собираем дамп:  
![дамп трафика](/dz14/pic/dz14_7_1.png)
  
Открываем в **Wireshark**'е:  
![Wireshark](/dz14/pic/dz14_7_2.png)

