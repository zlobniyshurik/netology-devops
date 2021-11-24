Домашнее задание 10
===================

Задача 1
--------

*Узнайте о sparse (разряженных) файлах.*  
  
Ознакомился, но я о них и так знал.

Задача 2
--------

*Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?*  
  
Не могут, ибо по сути своей - это всё алиасы одного и того же файла, у которого может быть только один  
набор разрешений и владельцев.

Задача 3
--------

*Сделайте* ***vagrant destroy*** на имеющийся инстанс Ubuntu. Замените содержимое ***Vagrantfile*** следующим:*  
  
```bash
    Vagrant.configure("2") do |config|
      config.vm.box = "bento/ubuntu-20.04"
      config.vm.provider :virtualbox do |vb|
        lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
        lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
        vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
        vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
      end
    end
```
  
Готово:  
![Диски в вагранте](/dz10/pic/dz10_3.png)

Задача 4
--------

*Используя* ***fdisk*** *, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.*
  
Сделано:  
![Разделы на /dev/sdb](/dz10/pic/dz10_4.png)

Задача 5
--------

*Используя* ***sfdisk*** *, перенесите данную таблицу разделов на второй диск.*  
  
Готово:  
![Разделы на /dev/sdc](/dz10/pic/dz10_5.png)

Задачи 6 и 7
------------

*Соберите* ***mdadm*** *RAID1 на паре разделов 2 Гб.*  
*Соберите* ***mdadm*** *RAID0 на второй паре маленьких разделов.*  
  
Как-то так:  
![Рейд на mdadm](/dz10/pic/dz10_6_7.png)

Задача 8
--------

*Создайте 2 независимых PV на получившихся md-устройствах*  
  
Готово:  
![PV-тома на md-девайсах](/dz10/pic/dz10_8.png)

Задача 9
--------

*Создайте общую volume-group на этих двух PV.*  
  
Сделано:  
![Volume group из PV-томов](/dz10/pic/dz10_9.png)

Задача 10
---------

*Создайте LV размером 100 Мб, указав его расположение на PV с RAID0*
  
Создано:  
![Создание LV](/dz10/pic/dz10_10.png)

Задача 11
---------

*Создайте mkfs.ext4 ФС на получившемся LV.*
  
Отформатировано:  
![Форматирование в ext4](/dz10/pic/dz10_11.png)

Задача 12
---------

*Смонтируйте этот раздел в любую директорию, например,* ***/tmp/new***  
  
Смонтировал (без fstab'а):  
![Монтирование в /new/tmp](/dz10/pic/dz10_12.png)

Задача 13
---------

*Поместите туда тестовый файл, например* ```bash wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz```  
  
Готово:  
![закачка файла](/dz10/pic/dz10_13.png)

Задача 14
---------

*Прикрепите вывод* ***lsblk***  
  
Вот оно:  
![Вывод lsblk](/dz10/pic/dz10_14.png)

Задача 15
---------

*Протестируйте целостность файла:*  
```bash
root@vagrant:~# gzip -t /tmp/new/test.gz
root@vagrant:~# echo $?
0
```
  
Протестировал:  
![Проверка на целостность](/dz10/pic/dz10_15.png)

Задача 16
---------

*Используя* ***pvmove*** *, переместите содержимое PV с RAID0 на RAID1.*  
  
Переместил:  
![Перемещение данных](/dz10/pic/dz10_16.png)

