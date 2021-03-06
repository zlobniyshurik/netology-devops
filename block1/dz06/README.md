Домашнее задание N06
====================

Задача 4
--------

В **Vagrantfile** пришлось добавить строчку  
**config.vm.provider "virtualbox"**  
  
Без неё **vagrant** упорно пытался скачать несуществующий образ для **libvirt**,  
который тоже присутствует на моей машине.

Задача 5
--------

**vagrant**овский вариант виртуальной машины  
![Vagrant_Ubuntu](/block1/dz06/pic/Vagrant_VM_settings.png)
  

**дефолтный** вариант виртуалки под убунту  
![Default_Ubuntu](/block1/dz06/pic/Default_VM_settings.png)
  

Задача 6
--------

Чтобы задать количество виртуальных ядер и памяти в виртуалке,  
прописываем в файле **Vagrantfile** секцию вида
  
 config.vm.provider "virtualbox" do |v|  
    v.memory = 1024  
    v.cpus = 2  
 end  

Задача 8
--------

Длина журнала **history** в запоминаемых командах регулируется переменной **HISTSIZE**,  
о чём подробно расписано на **779-782**ой строках мануала  
  
***ignoreboth*** - это комбинация двух опций:  
***ignorespace*** (не запоминать команды, начинающиеся на пробел)  
и  
***ignoredups*** (не запоминать команды, которые уже есть в истории команд)  

Задача 9
--------

Про { list } написано с 238 строки мануала.  
В данном случае,  выполняется список команд (list) в уже запущенной оболочке с установленными на текущий момент переменными окружения.  
Результатом будет exitcode последней команды из списка команд.

Задача 10
---------

Создать 100000 файлов можно командой вида  
**touch test{00000..99999}**  

При попытке создания 300000 файлов таким методом выдаст ошибку  
***-bash: /usr/bin/touch: Argument list too long***  
Ибо сгенерённый bash'ем список команд на создание файлов тупо не влезет в память.  
  
Если 300000 файлов таки нужны, придётся обратиться к циклам  

Задача 11
---------

Конструкция **[[ -d /tmp ]]** выдаёт истину *(True)*, если каталог **/tmp** существует (**-d /tmp** exitcode равен 0)

Задача 12
---------

Примерно так...
![bash_path](/block1/dz06/pic/bash_path.png)

Задача 13
---------

**at** - запускает команду (или пакет команд) в жёстко заданное время  
  
**batch** - запускает команду (или пакет команд) во время, когда загрузка процессора упала ниже предопределённого значения..

