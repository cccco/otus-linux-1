# Networking

Задание:  
Разворачиваем сетевую лабораторию

# Дано
Vagrantfile с начальным построением сети
- inetRouter
- centralRouter
- centralServer

# Планируемая архитектура
построить следующую архитектуру

Сеть office1
- 192.168.2.0/26 - dev
- 192.168.2.64/26 - test servers
- 192.168.2.128/26 - managers
- 192.168.2.192/26 - office hardware

Сеть office2
- 192.168.1.0/25 - dev
- 192.168.1.128/26 - test servers
- 192.168.1.192/26 - office hardware


Сеть central
- 192.168.0.0/28 - directors
- 192.168.0.32/28 - office hardware
- 192.168.0.64/26 - wifi

```
Office1 ---\
-----> Central --IRouter --> internet
Office2----/
```
Итого должны получится следующие сервера
- inetRouter
- centralRouter
- office1Router
- office2Router
- centralServer
- office1Server
- office2Server

# Теоретическая часть
- Найти свободные подсети
- Посчитать сколько узлов в каждой подсети, включая свободные
- Указать broadcast адрес для каждой подсети
- проверить нет ли ошибок при разбиении

# Практическая часть
- Соединить офисы в сеть согласно схеме и настроить роутинг
- Все сервера и роутеры должны ходить в инет черз inetRouter
- Все сервера должны видеть друг друга
- у всех новых серверов отключить дефолт на нат (eth0), который вагрант поднимает для связи
- при нехватке сетевых интервейсов добавить по несколько адресов на интерфейс

---

### Теорерическая часть

![network](https://github.com/sinist3rr/otus-linux/blob/master/HW15/images/net1.png)


Свободная подсеть в Central: 192.168.0.16/28    

Сводная информация по сетям - количество хостов и широковещательные адреса:      

**Сеть office1**:   

- 192.168.2.0/26 - dev

Broadcast: 192.168.2.63
Hosts:     62

- 192.168.2.64/26 - test servers

Broadcast: 192.168.2.127
Hosts: 	   62

- 192.168.2.128/26 - managers

Broadcast: 192.168.2.191
Hosts:     62

- 192.168.2.192/26 - office hardware

Broadcast: 192.168.2.255
Hosts: 	   62

**Сеть office2**:    

- 192.168.1.0/25 - dev

Broadcast: 192.168.1.127
Hosts:     126

- 192.168.1.128/26 - test servers

Broadcast: 192.168.1.191
Hosts:     62

- 192.168.1.192/26 - office hardware

Broadcast: 192.168.1.255
Hosts: 	   62

**Сеть central**:    

- 192.168.0.0/28 - directors

Broadcast: 192.168.0.15
Hosts: 	   14

- 192.168.0.32/28 - office hardware

Broadcast: 192.168.0.47
Hosts: 	   14

- 192.168.0.64/26 - wifi

Broadcast: 192.168.0.127
Hosts: 	   62    


При разбиении ошибки не обнаружены. Есть небольшая неоднородность в сети Сentral, но возможно так и было запланировано. 

### Практическая часть

Для запуска: 

```console
vagrant up
```

Проверить результаты:

```console
[vagrant@office1Server ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=57 time=18.6 ms
^C
--- 8.8.8.8 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 18.677/18.677/18.677/0.000 ms

[vagrant@office1Server ~]$ tracepath -n 8.8.8.8
 1?: [LOCALHOST]                                         pmtu 1500
 1:  192.168.2.1                                           0.742ms 
 1:  192.168.2.1                                           0.422ms 
 2:  192.168.20.2                                          0.838ms 
 3:  192.168.255.1                                         1.273ms 
^C

[vagrant@office1Server ~]$ ping 192.168.1.2    
PING 192.168.1.2 (192.168.1.2) 56(84) bytes of data.
64 bytes from 192.168.1.2: icmp_seq=1 ttl=61 time=2.76 ms
64 bytes from 192.168.1.2: icmp_seq=2 ttl=61 time=2.25 ms
^C
--- 192.168.1.2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 2.253/2.508/2.764/0.260 ms

[vagrant@office1Server ~]$ tracepath -n 192.168.1.2
 1?: [LOCALHOST]                                         pmtu 1500
 1:  192.168.2.1                                           0.594ms 
 1:  192.168.2.1                                           0.606ms 
 2:  192.168.20.2                                          0.974ms 
 3:  192.168.10.1                                          1.195ms 
 4:  192.168.1.2                                           1.628ms reached
     Resume: pmtu 1500 hops 4 back 4 

```

