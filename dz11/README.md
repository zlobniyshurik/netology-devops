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


