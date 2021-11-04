Домашнее задание N05
====================

Задача 1
--------

*Найдите полный хеш и комментарий коммита, хеш которого начинается на* ***aefea***
  
**git show aefea --pretty=format:"hash:%H%nSubject:%s" -s**
  
hash:aefead2207ef7e2aa5dc81a34aedf0cad4c32545  
Subject:Update CHANGELOG.md

Задача 2
--------

*Какому тегу соответствует коммит* ***85024d3*** *?*
  
**git show 85024d3 --pretty=format:%D -s**
  
tag: v0.12.23

Задача 3
--------

*Сколько родителей у коммита* ***b8d720*** *? Напишите их хеши.*
  
Судя по всему, родителей двое.
  
**git show b8d720 --pretty=format:%P -s**
  
56cd7859e05c36c06b56d013b55a252d0bb7e158 9ea88f22fc6269854151c571162c5bcf958bee2b
  
или
  
**git rev-parse b8d720^@**
  
56cd7859e05c36c06b56d013b55a252d0bb7e158  
9ea88f22fc6269854151c571162c5bcf958bee2b

Задача 4
--------

*Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами* ***v0.12.23*** *и* ***v0.12.24***

1. Вычисляем хэши граничных коммитов
  
**git rev-list -n 1 "v0.12.23"**
  
85024d3100126de36331c6982bfaac02cdab9e76
  
**git rev-list -n 1 "v0.12.24"**
  
33ff1c03bb960b332be3af2e333462dde88b279e
  
2. На основе полученных хэшей выводим данные по коммитам
  
**git show 85024d3100126de36331c6982bfaac02cdab9e76..33ff1c03bb960b332be3af2e333462dde88b279e --pretty=format:"Хэш:%H%nКоммментарий:%s%n" -s**
  
Хэш:33ff1c03bb960b332be3af2e333462dde88b279e  
Коммментарий:v0.12.24

Хэш:b14b74c4939dcab573326f4e3ee2a62e23e12f89  
Коммментарий:[Website] vmc provider links

Хэш:3f235065b9347a758efadc92295b540ee0a5e26e  
Коммментарий:Update CHANGELOG.md

Хэш:6ae64e247b332925b872447e9ce869657281c2bf  
Коммментарий:registry: Fix panic when server is unreachable

Хэш:5c619ca1baf2e21a155fcdb4c264cc9e24a2a353  
Коммментарий:website: Remove links to the getting started guide's old location

Хэш:06275647e2b53d97d4f0a19a0fec11f6d69820b5  
Коммментарий:Update CHANGELOG.md

Хэш:d5f9411f5108260320064349b757f55c09bc4b80  
Коммментарий:command: Fix bug when using terraform login on Windows

Хэш:4b6d06cc5dcb78af637bbb19c198faff37a066ed  
Коммментарий:Update CHANGELOG.md

Хэш:dd01a35078f040ca984cdd349f18d0b67e486c35  
Коммментарий:Update CHANGELOG.md

Хэш:225466bc3e5f35baa5d07197bbc079345b77525e  
Коммментарий:Cleanup after v0.12.23 release

Задача 5
--------

*Найдите коммит в котором была создана функция* ***func providerSource*** *, ее определение в коде выглядит так* ***func providerSource(...)*** *(вместо троеточего перечислены аргументы).*
  
**git log -S "func providerSource" --reverse --oneline**
  
8c928e835 main: Consult local directories as potential mirrors of providers  
5af1e6234 main: Honor explicit provider_installation CLI config when present

Самый первый коммит в хронологическом порядке (**8c928e835**) - тот, что нам нужен.

Задача 6
--------

*Найдите все коммиты в которых была изменена функция* ***globalPluginDirs***

1. Ищем коммит, где впервые упоминается функция **globalPluginDirs**

**git log -S "globalPluginDirs" --reverse --oneline**

8364383c3 Push plugin discovery down into command package  
c0b176109 prevent log output during init  
35a058fb3 main: configure credentials from the CLI config file  

Самый первый коммит в хронологическом порядке (**8364383c3**) - тот, что нам нужен.

2. Вычисляем файл, где живёт **globalPluginDirs**

Не придумал как это красиво сделать в git`е - обошёлся поиском в текстовом редакторе. 

**git show 8364383c3 > /home/shurik/zzz.txt**

Файлом оказался **plugins.go**

3. Вычисляем коммиты, где изменялась функция **globalPluginDirs**

**git log -L:globalPluginDirs:plugins.go -s --oneline**

78b122055 Remove config.go and update things using its aliases  
52dbf9483 keep .terraform.d/plugins for discovery  
41ab0aef7 Add missing OS_ARCH dir to global plugin paths  
66ebff90c move some more plugin search path logic to command  
8364383c3 Push plugin discovery down into command package  

Задача 7
--------

*Кто автор функции* ***synchronizedWriters*** *?*


