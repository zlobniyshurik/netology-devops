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
