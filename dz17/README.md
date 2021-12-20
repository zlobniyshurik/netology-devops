### Как сдавать задания

Вы уже изучили блок «Системы управления версиями», и начиная с этого занятия все ваши работы будут приниматься ссылками на .md-файлы, размещённые в вашем публичном репозитории.

Скопируйте в свой .md-файл содержимое этого файла; исходники можно посмотреть [здесь](https://raw.githubusercontent.com/netology-code/sysadm-homeworks/devsys10/04-script-03-yaml/README.md). Заполните недостающие части документа решением задач (заменяйте `???`, ОСТАЛЬНОЕ В ШАБЛОНЕ НЕ ТРОГАЙТЕ чтобы не сломать форматирование текста, подсветку синтаксиса и прочее, иначе можно отправиться на доработку) и отправляйте на проверку. Вместо логов можно вставить скриншоты по желани.

# Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"


## Обязательная задача 1
Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```
    { "info" : "Sample JSON output from our service\\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            }
            { "name" : "second",
            "type" : "proxy",
            "ip" : "71.78.22.43"
            }
        ]
    }
```
  Нужно найти и исправить все ошибки, которые допускает наш сервис

## Обязательная задача 2
В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`. Формат записи YAML по одному сервису: `- имя сервиса: его IP`. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import socket
import time
import yaml
import json

hosts = ["drive.google.com", "mail.google.com", "google.com"]

yamlfilename = "./iptest.yml"

jsonfilename = "./iptest.json"

spisok = {}

while True:

  #Проверяем хосты по списку
  for host in hosts:
    newip = socket.gethostbyname(host)
    isModified = False

    #Если хост ещё ни разу не проверялся - заносим в словарь
    if host not in spisok:
      spisok[host]=newip
      print(f'Found new host {host} with ip={newip}')
      isModified = True

    #Проверяем - отличается ли старый IP от нового?
    if newip != spisok[host]:
      print(f'[ERROR] {host} IP mismatch: {spisok[host]} {newip}')
      spisok[host] = newip
      isModified = True

    #Если были изменения, сливаем дампы в JSON и YAML
    if isModified:

      with open(yamlfilename,'w') as yf:
        yf.write(yaml.dump(spisok, indent = 2, explicit_start = True, explicit_end = True))

      with open(jsonfilename,'w') as jf:
        jf.write(json.dumps(spisok))

  #Задержка в 5 секунд после каждого цикла опросов
  time.sleep(5)
```

### Вывод скрипта при запуске при тестировании:
```
[shurik@megaboss ~]$ ./test3.py
Found new host drive.google.com with ip=108.177.119.194
Found new host mail.google.com with ip=64.233.161.19
Found new host google.com with ip=64.233.161.101
[ERROR] mail.google.com IP mismatch: 64.233.161.19 64.233.161.18
[ERROR] google.com IP mismatch: 64.233.161.101 64.233.161.139
^CTraceback (most recent call last):
  File "/home/shurik/./test3.py", line 45, in <module>
    time.sleep(5)
KeyboardInterrupt


[shurik@megaboss ~]$
```

### json-файл(ы), который(е) записал ваш скрипт:
```json
{"drive.google.com": "108.177.119.194", "mail.google.com": "64.233.161.18", "google.com": "64.233.161.139"}
```

### yml-файл(ы), который(е) записал ваш скрипт:
```yaml
---
drive.google.com: 108.177.119.194
google.com: 64.233.161.139
mail.google.com: 64.233.161.18
...
```

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Так как команды в нашей компании никак не могут прийти к единому мнению о том, какой формат разметки данных использовать: JSON или YAML, нам нужно реализовать парсер из одного формата в другой. Он должен уметь:
   * Принимать на вход имя файла
   * Проверять формат исходного файла. Если файл не json или yml - скрипт должен остановить свою работу
   * Распознавать какой формат данных в файле. Считается, что файлы *.json и *.yml могут быть перепутаны
   * Перекодировать данные из исходного формата во второй доступный (из JSON в YAML, из YAML в JSON)
   * При обнаружении ошибки в исходном файле - указать в стандартном выводе строку с ошибкой синтаксиса и её номер
   * Полученный файл должен иметь имя исходного файла, разница в наименовании обеспечивается разницей расширения файлов

### Ваш скрипт:
```python
???
```

### Пример работы скрипта:
???
