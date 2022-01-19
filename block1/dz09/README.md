Домашнее задание N09
====================

Задача 1
--------

*На лекции мы познакомились с* ***node_exporter*** *. В демонстрации его исполняемый файл запускался в  
background. Этого достаточно для демо, но не для настоящей production-системы, где процессы должны находиться  
под внешним управлением. Используя знания из лекции по systemd, создайте самостоятельно простой unit-файл для* ***node_exporter*** *:*  
  
+    *поместите его в автозагрузку,*
+    *предусмотрите возможность добавления опций к запускаемому процессу через внешний файл (посмотрите, например, на* ***systemctl cat cron*** *),*
+    *удостоверьтесь, что с помощью systemctl процесс корректно стартует, завершается, а после перезагрузки автоматически поднимается.*

Если сделать unit-файл примерно такого содержания, то оно даже заработает...  

    [Unit]  
    Description=Node Exporter  
      
    [Service]  
    EnvironmentFile=-/etc/sysconfig/node_exporter  
    ExecStart=/opt/node_exporter/node_exporter $OPTIONS  
      
    [Install]  
    WantedBy=multi-user.target  
  
Результат:
![Запущенный Node exporter](/block1/dz09/pic/node_status.png)

Задача 2
--------

*Ознакомьтесь с опциями* ***node_exporter*** *и выводом* ***/metrics*** *по-умолчанию. Приведите несколько опций,  
которые вы бы выбрали для базового мониторинга хоста по CPU, памяти, диску и сети.*  

**CPU:**  
+ node_cpu_seconds_total  
+ node_cpu_guest_seconds_total  

**память:**  
+ node_memory_Buffers_bytes  
+ node_memory_Cached_bytes  
+ node_memory_SwapFree_bytes  
+ node_memory_SwapTotal_bytes  
+ node_memory_HardwareCorrupted_bytes  
+ node_memory_MemAvailable_bytes  
+ node_memory_MemFree_bytes  
+ node_memory_MemTotal_bytes  

**диск:**  
+ node_disk_info  
+ node_disk_io_now  
+ node_disk_io_time_seconds_total  
+ node_disk_io_time_weighted_seconds_total  
+ node_disk_read_bytes_total  
+ node_disk_read_time_seconds_total  
+ node_disk_reads_completed_total  
+ node_disk_reads_merged_total  
+ node_disk_write_time_seconds_total  
+ node_disk_writes_completed_total  
+ node_disk_writes_merged_total  
+ node_disk_written_bytes_total  

**сеть:**  
+ node_network_up  
+ node_network_speed_bytes  
+ node_network_transmit_bytes_total  
+ node_network_transmit_errs_total  
+ node_network_transmit_queue_length  
+ node_network_receive_bytes_total  
+ node_network_receive_errs_total  
  
P.S. Возможно, половина этих данных не нужна, но пока не увижу это всё в графическом представлении - не узнаю.  

Задача 3
--------

*Установите в свою виртуальную машину* ***Netdata*** *. Воспользуйтесь готовыми пакетами для установки*  
***(sudo apt install -y netdata)*** *. После успешной установки:*  
  
*в конфигурационном файле* ***/etc/netdata/netdata.conf*** *в секции* ***[web]***  
*замените значение с* ***localhost*** *на* ***bind to = 0.0.0.0,***  
  
*добавьте в* ***Vagrantfile*** *проброс порта* ***Netdata*** *на свой локальный компьютер и сделайте* ***vagrant reload*** *:*  
  
    config.vm.network "forwarded_port", guest: 19999, host: 19999  
  
*После успешной перезагрузки в браузере на своем ПК (не в виртуальной машине) вы должны суметь зайти на* ***localhost:19999***  
*. Ознакомьтесь с метриками, которые по умолчанию собираются* ***Netdata*** *и с комментариями, которые даны к этим метрикам.*  
  
![Netdata](/block1/dz09/pic/netdata.png)
  
Красиво, забавно, но у меня уже везде поднят **Zabbix**.  

Задача 4
--------

*Можно ли по выводу* ***dmesg*** понять, осознает ли ОС, что загружена не на настоящем оборудовании,  
а на системе виртуализации?*  
  
Можно.  
![Запуск на виртуалке](/block1/dz09/pic/dmesg_virt.png)

Задача 5
--------

*Как настроен* ***sysctl fs.nr_open*** *на системе по-умолчанию? Узнайте, что означает  
этот параметр. Какой другой существующий лимит не позволит достичь такого числа* ***(ulimit --help)*** *?*

**fs.nr_open** - максимальное количество открытых файлов в системе.  
По умолчанию задано 1048576, это hard limit.  
  
Но мы до этого числа без дополнительного тюнинга настроек не доберёмся,  
ибо есть ещё soft limit для пользователей **(ulimit -aS)** в жалкие 1024 файла по умолчанию.  

Задача 6
--------

*Запустите любой долгоживущий процесс (не* ***ls*** *, который отработает мгновенно, а, например,* ***sleep 1h*** *)  
в отдельном неймспейсе процессов; покажите, что ваш процесс работает под PID 1 через* ***nsenter*** *.  
Для простоты работайте в данном задании под root (* ***sudo -i*** *). Под обычным пользователем требуются дополнительные  
опции (--map-root-user) и т.д.*  
  
**unshare**:  
![unshare](/block1/dz09/pic/unshare.png)
  
**nsenter**:  
![nsenter](/block1/dz09/pic/nsenter.png)

Задача 7
--------

*Найдите информацию о том, что такое* ***<code>:\(\)\{ :|:& \};:</code>*** *. Запустите эту команду в своей виртуальной машине  
Vagrant с Ubuntu 20.04 (это важно, поведение в других ОС не проверялось). Некоторое время все будет "плохо",  
после чего (минуты) – ОС должна стабилизироваться. Вызов* ***dmesg*** *расскажет, какой механизм помог автоматической  
стабилизации. Как настроен этот механизм по-умолчанию, и как изменить число процессов, которое можно создать в сессии?*  
  
**<code>:\(\)\{ :|:& \};:</code>** - это форк-бомба. Функция с именем **:** рекурсивно вызывает сама себя,  
каждый раз отправляя ещё одну свою запущенную копию в фоновые процессы.  
Что, в конце концов, приводит к исчерпанию системных ресурсов.  
  
Конец безобразию положат ограничения в **cgroups**:  
![fork rejected](/block1/dz09/pic/fork_rejected.png)
