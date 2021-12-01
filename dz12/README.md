Домашняя работа N12
===================

Задача 1
--------
*Проверьте список доступных сетевых интерфейсов на вашем компьютере. Какие команды есть для этого в Linux и в Windows?*  
  
В Windows обычно это **ipconfig**:  
![ipconfig](/dz12/pic/dz12_1_1.png)
  
В линуксе вариантов больше:  
  
**ifconfig**  
![ifconfig](/dz12/pic/dz12_1_2.png)
  
**ip**  
![ip](/dz12/pic/dz12_1_3.png)
  
**networkctl**  
![networkctl](/dz12/pic/dz12_1_4.png)
  
и ещё пачка других вариантов.  

Задача 2
--------
*Какой протокол используется для распознавания соседа по сетевому интерфейсу? Какой пакет и команды есть в Linux для этого?*  
  
Нам нужен протокол **LLDP** (проприетарные неинтересны).  
Пакеты в разных дистрибутивах зовутся по разному, но обычно это **lldpd**  
  
Пример обнаружения соседей через **lldp**:  
```bash
[root@juggernaut etc]# lldpctl
-------------------------------------------------------------------------------
LLDP neighbors:
-------------------------------------------------------------------------------
Interface:    enp7s0, via: LLDP, RID: 1, Time: 0 day, 00:00:57
  Chassis:     
    ChassisID:    mac aa:bb:cc:dd:ee:ff
    SysName:      Zyxel
    SysDescr:     GS1900-8
    MgmtIP:       192.168.xxx.xxx
    Capability:   Bridge, on
  Port:        
    PortID:       local 3
    PortDescr:    First Comp
    TTL:          120
    PMD autoneg:  supported: yes, enabled: yes
      Adv:          10Base-T, HD: yes, FD: yes
      Adv:          100Base-TX, HD: yes, FD: yes
      Adv:          1000Base-T, HD: no, FD: yes
      MAU oper type: 1000BaseTFD - Four-pair Category 5 UTP, full duplex mode
  VLAN:         1, pvid: yes
  Unknown TLVs:
    TLV:          OUI: 00,A0,C5, SubType: 2, Len: 9 08,47,53,31,39,30,30,2D,38
    TLV:          OUI: 00,A0,C5, SubType: 3, Len: 27 1A,56,32,2E,36,30,28,41,41,48,48,2E,34,29,20,7C,20,30,35,2F,32,34,2F,32,30,32,31
    TLV:          OUI: 00,A0,C5, SubType: 4, Len: 18 11,43,38,2D,35,34,2D,34,42,2D,46,36,2D,37,32,2D,33,43
    TLV:          OUI: 00,A0,C5, SubType: 5, Len: 22 15,68,74,74,70,3A,2F,2F,31,39,32,2E,31,36,38,2E,31,2E,32,35,31,2F
    TLV:          OUI: 00,A0,C5, SubType: 7, Len: 9 08,4D,61,69,6E,42,61,73,65
-------------------------------------------------------------------------------
```

Задача 3
--------
*Какая технология используется для разделения L2 коммутатора на несколько виртуальных сетей?  
Какой пакет и команды есть в Linux для этого? Приведите пример конфига.*  
  
Для разбиения одной сети на несколько виртуальных используется технология VLAN'ов.  
  
Пакеты поддержки VLAN'ов для разных Linux-дистрибутивов называются по разному,  
в убунте это пакет **vlan**, а где-то и просто **vconfig**  
  
Пример конфига ***/etc/network/interfaces*** в убунте для 999го VLANа на интерфейсе eth1:  

```bash
auto eth1.999
iface eth1.999 inet static
        address 192.168.1.1
        netmask 255.255.255.0
        vlan_raw_device eth1
```

Задача 4
--------

