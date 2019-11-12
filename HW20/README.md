# VLAN

Задание:  

В Office1 в тестовой подсети появляется сервер с доп. интерфесами и адресами в internal сети testLAN:
- testClient1 - 10.10.10.254
- testClient2 - 10.10.10.254
- testServer1- 10.10.10.1
- testServer2- 10.10.10.1

Изолировать с помощью vlan:
testClient1 <-> testServer1
testClient2 <-> testServer2

Между centralRouter и inetRouter создать 2 линка (общая inernal сеть) и объединить их с помощью bond-интерфейса,
проверить работу c отключением сетевых интерфейсов


---

### Топология

![vlan](https://github.com/sinist3rr/otus-linux/blob/master/HW20/images/vlan1.png)

### Запуск

Реализовано в виде одной роли ansible.   

Для запуска: 

```console
vagrant up
```

### VLAN

Проверяем что получилось:

```console

[root@testServer1 ~]# ip -c a show eth1.10 
5: eth1.10@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:68:46:7e brd ff:ff:ff:ff:ff:ff
    inet 10.10.10.1/24 brd 10.10.10.255 scope global noprefixroute eth1.10
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe68:467e/64 scope link 
       valid_lft forever preferred_lft forever


[root@testClient1 ~]# ip -c a show eth1.10
6: eth1.10@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:03:bb:fe brd ff:ff:ff:ff:ff:ff
    inet 10.10.10.254/24 brd 10.10.10.255 scope global noprefixroute eth1.10
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe03:bbfe/64 scope link 
       valid_lft forever preferred_lft forever


[root@testClient1 ~]# ping -c 5 10.10.10.1
PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
64 bytes from 10.10.10.1: icmp_seq=1 ttl=64 time=0.692 ms
64 bytes from 10.10.10.1: icmp_seq=2 ttl=64 time=0.499 ms
64 bytes from 10.10.10.1: icmp_seq=3 ttl=64 time=0.506 ms
64 bytes from 10.10.10.1: icmp_seq=4 ttl=64 time=0.485 ms
64 bytes from 10.10.10.1: icmp_seq=5 ttl=64 time=0.507 ms

--- 10.10.10.1 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4001ms
rtt min/avg/max/mdev = 0.485/0.537/0.692/0.082 ms

```

Видим, что vlan появился и пинги ходят.

```console

[root@testClient1 ~]# ip n
10.10.10.1 dev eth1.10 lladdr 08:00:27:68:46:7e REACHABLE
10.0.2.2 dev eth0 lladdr 52:54:00:12:35:02 REACHABLE

[root@testServer1 ~]# ip n
10.0.2.2 dev eth0 lladdr 52:54:00:12:35:02 REACHABLE
10.10.10.254 dev eth1.10 lladdr 08:00:27:03:bb:fe REACHABLE

```

При этом, в ARP таблице тоже всё что нужно и ничего лишнего. 

### Bonding

Пробуем отключить один интерфейс и проверить не прервется ли пинг: 


```console

```

