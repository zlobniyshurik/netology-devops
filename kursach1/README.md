Курсовая работа по итогам модуля "DevOps и системное администрирование"
=======================================================================

Пункт 1
-------

*Создайте виртуальную машину Linux.*

В наличии имеется хост на **Fedora35** с KVM-гипервизором и готовым шаблоном  
**Alma Linux 8.5** (немного перелицованный **CentOS 8.5** в минимальной установке)  
С ними и будем работать.  
  
+ На основе готового шаблона создаём клонированием виртуалку **Kursach**  
  
+ Через **nmtui** вбиваем статические IPv4/IPv6-адреса, адреса шлюза и DNS'а в сетевые настройки  
и там же меняем имя виртуалки на **kursach.mydomain.tld**  
  
+ Перезапускаем систему через **reboot**  
  
+ Получаем примерно такую картинку:  
![Виртуалка](/kursach1/pic/k1_1.png)
  
+ Меняем пароль через **passwd**  
  
+ Не забываем сменить SSH-ключи на несовпадающие с шаблоном:  
```bash
rm -f /etc/ssh/ssh_host*
ssh-keygen -A
```
  
+ Всё, дальше уже можно с комфортом работать с виртуалкой через SSH  

Пункт 2
-------

*Установите* ***ufw*** *и разрешите к этой машине сессии на порты 22 и 443, при этом трафик на  
интерфейсе* ***localhost (lo)*** *должен ходить свободно на все порты.*  
  
Согласно экспертам, тип фаервола нам не важен - лишь бы нужные порты были открыты,  
а остальное надёжно защищено.  
  
У нас уже есть установленный по умолчанию **firewalld** - вот им и будем пользоваться.  
  
Смотрим текущую ситуацию через ```bash firewall-cmd --list-all-zones```:  
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
  
Хотелось бы ограничиться вообще двумя зонами:  
+ **work** - с разрешённым доступом через **SSH** с определённого IP (админская машина)  
  
+ **public** - с открытыми портами **80** (для HTTP) и **443** (для HTTPS) для доступа к сайту с любых IP-адресов,  
стучащихся на сетевой интерфейс **enp1s0**  
  
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
  sources: 192.168.1.99
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
  
Стоило ли возиться с **firewalld** вместо **ufw**?  
Уже не уверен, впрочем, новые знания получены, так что стоило...  

Задача 3
--------
*Установите* ***hashicorp vault***

