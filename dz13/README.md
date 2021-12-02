Домашняя работа N13
===================

Подзадача 1
-----------
*Подключитесь к публичному маршрутизатору в интернет. Найдите маршрут к вашему публичному IP*  
```bash
telnet route-views.routeviews.org
Username: rviews
show ip route x.x.x.x/32
show bgp x.x.x.x/32
```
  
На запрос IP маршрута выдало:  
```bash
route-views>show ip route 37.194.xxx.xxx
Routing entry for 37.194.0.0/16
  Known via "bgp 6447", distance 20, metric 0
  Tag 6939, type external
  Last update from 64.71.137.241 2w6d ago
  Routing Descriptor Blocks:
  * 64.71.137.241, from 64.71.137.241, 2w6d ago
      Route metric is 0, traffic share count is 1
      AS Hops 3
      Route tag 6939
      MPLS label: none
```
  
На запрос BGP выдало длиннющую простыню (всю не привожу):  
```bash
route-views>show bgp 37.194.xxx.xxx
BGP routing table entry for 37.194.0.0/16, version 1332509491
Paths: (24 available, best #23, table default)
  Not advertised to any peer
  Refresh Epoch 1
  4901 6079 9002 9002 9049 31200, (aggregated by 31200 178.49.135.253)
    162.250.137.254 from 162.250.137.254 (162.250.137.254)
      Origin IGP, localpref 100, valid, external
      Community: 65000:10100 65000:10300 65000:10400
      path 7FE04F55F5C8 RPKI State valid
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 3
  3303 12389 31200, (aggregated by 31200 10.245.140.238)
    217.192.89.50 from 217.192.89.50 (138.187.128.158)
      Origin IGP, localpref 100, valid, external
      Community: 3303:1004 3303:1006 3303:1030 3303:3056
      path 7FE151A8A448 RPKI State valid
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  7660 2516 12389 31200, (aggregated by 31200 10.245.140.238)
    203.181.248.168 from 203.181.248.168 (203.181.248.168)
      Origin IGP, localpref 100, valid, external
      Community: 2516:1050 7660:9001
      path 7FE0112DA190 RPKI State valid
      rx pathid: 0, tx pathid: 0
    ....

```

Задача 2
--------
*Создайте* ***dummy0*** *интерфейс в Ubuntu. Добавьте несколько статических маршрутов. Проверьте таблицу маршрутизации.*  
  
Добавил **dummy0**:  
```bash
root@vagrant:/home/vagrant# ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:73:60:cf brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 08:00:27:70:a8:22 brd ff:ff:ff:ff:ff:ff
4: dummy0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/ether 1a:09:e7:b7:60:8a brd ff:ff:ff:ff:ff:ff
root@vagrant:/home/vagrant# ip address
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:73:60:cf brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic eth0
       valid_lft 86361sec preferred_lft 86361sec
    inet6 fe80::a00:27ff:fe73:60cf/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 08:00:27:70:a8:22 brd ff:ff:ff:ff:ff:ff
4: dummy0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default qlen 1000
    link/ether 1a:09:e7:b7:60:8a brd ff:ff:ff:ff:ff:ff
    inet 10.1.2.3/32 brd 10.1.2.3 scope global dummy0
       valid_lft forever preferred_lft forever
    inet6 fe80::1809:e7ff:feb7:608a/64 scope link 
       valid_lft forever preferred_lft forever
```
  
Добавляем маршруты и смотрим таблицу маршрутизации:  
```bash
root@vagrant:/home/vagrant# ip route
default via 10.0.2.2 dev eth0 proto dhcp src 10.0.2.15 metric 100 
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 
10.0.2.2 dev eth0 proto dhcp scope link src 10.0.2.15 metric 100
root@vagrant:/home/vagrant# ip route add 1.1.1.0/24 via 10.0.2.5
root@vagrant:/home/vagrant# ip route add 1.1.0.0/16 via 10.0.2.6
root@vagrant:/home/vagrant# ip route add 1.0.0.0/8 via 10.0.2.7
root@vagrant:/home/vagrant# ip route add 9.0.0.0/8 via 10.0.2.7
root@vagrant:/home/vagrant# ip route
default via 10.0.2.2 dev eth0 proto dhcp src 10.0.2.15 metric 100 
1.0.0.0/8 via 10.0.2.7 dev eth0 
1.1.0.0/16 via 10.0.2.6 dev eth0 
1.1.1.0/24 via 10.0.2.5 dev eth0 
9.0.0.0/8 via 10.0.2.7 dev eth0 
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 
10.0.2.2 dev eth0 proto dhcp scope link src 10.0.2.15 metric 100
```

Задача 3
--------
*Проверьте открытые TCP порты в Ubuntu, какие протоколы и приложения используют эти порты? Приведите несколько примеров.*  
  
Смотрим TCP-порты и открывшие их приложения:  
```bash
root@vagrant:/home/vagrant# ss -tpan
State     Recv-Q    Send-Q       Local Address:Port        Peer Address:Port     Process                                                      
LISTEN    0         4096               0.0.0.0:111              0.0.0.0:*         users:(("rpcbind",pid=592,fd=4),("systemd",pid=1,fd=35))    
LISTEN    0         4096         127.0.0.53%lo:53               0.0.0.0:*         users:(("systemd-resolve",pid=593,fd=13))                   
LISTEN    0         128                0.0.0.0:22               0.0.0.0:*         users:(("sshd",pid=805,fd=3))                               
ESTAB     0         0                10.0.2.15:22              10.0.2.2:46490     users:(("sshd",pid=998,fd=4),("sshd",pid=806,fd=4))         
LISTEN    0         4096                  [::]:111                 [::]:*         users:(("rpcbind",pid=592,fd=6),("systemd",pid=1,fd=37))    
LISTEN    0         128                   [::]:22                  [::]:*         users:(("sshd",pid=805,fd=4))
```
**22 порт** - SSH (в нашем случае используется **sshd**)  
**53 порт** - DNS (в нашем случае используется **systemd-resolve**)  
**111 порт** - sunrpc (вроде бы нужен для NFS)  

Задача 4
--------
