# OSPF

Задание:  
- Поднять три виртуалки
- Объединить их разными private network
1. Поднять OSPF между машинами на базе Quagga
2. Изобразить ассиметричный роутинг
3. Сделать один из линков "дорогим", но что бы при этом роутинг был симметричным

---

### Топология

![ospf](https://github.com/sinist3rr/otus-linux/blob/master/HW18/images/ospf1.png)

Для запуска: 

```console
vagrant up
```

### Ассиметричная маршрутизация

Ассиметрия была создана на маршрутизаторе R1 используя команду bandwidth:

```
interface eth1
 bandwidth 1000
```

В результате трафик в сеть 192.168.20.0/24 стал идти через маршрутизатор R3:

```console
R1# sh ip route 192.168.20.1
Routing entry for 192.168.20.0/24
  Known via "ospf", distance 110, metric 30, best
  Last update 00:16:50 ago
  * 10.2.0.2, via eth2
```

Проверяем установилось ли соседство по OSPF:

```console
R1# sh ip ospf neighbor  

    Neighbor ID Pri State           Dead Time Address         Interface            RXmtL RqstL DBsmL
3.3.3.3           1 Full/Backup       33.805s 10.2.0.2        eth2:10.2.0.1            0     0     0
2.2.2.2           1 Full/DR           33.034s 10.1.0.2        eth1:10.1.0.1            0     0     0
```

### Исправление ассиметрии

Соответственно, для исправления созданной ассиметрии можно поднять стоимость линка между маршрутизаторами R1-R3, в таком случае трафик пойдет по кратчайшему пути.

```console
R1(config)# int eth2
R1(config-if)# ip ospf cost 133
```

Проверяем таблицу маршрутизации:

```console
R1# sh ip route 192.168.20.1
Routing entry for 192.168.20.0/24
  Known via "ospf", distance 110, metric 110, best
  Last update 00:00:05 ago
  * 10.1.0.2, via eth1
```

Видим, что несмотря на то что метрика выросла, трафик теперь пойдет по кратчайшему пути (R1->R2).

