# VPN

Задание:  

1. Между двумя виртуалками поднять vpn в режимах: 
- tun
- tap
Прочуствовать разницу. 

2. Поднять RAS на базе OpenVPN с клиентскими сертификатами, подключиться с локальной машины на виртуалку 
---

### TUN/TAP

Устанавливаем сервер: 

```console
[root@server ~]# yum -y install epel-release
[root@server ~]# yum install -y openvpn iperf3 policycoreutils-python
```
Генерируем ключ: 

```console
[root@server ~]# openvpn --genkey --secret /etc/openvpn/static.key
```

Конфиг сервера:  

```
dev tap
proto udp

ifconfig 10.10.10.1 255.255.255.0
topology subnet

secret /etc/openvpn/static.key

status /var/log/openvpn-status.log
log /var/log/openvpn.log

verb 3
```

Запускаем сервер:  

```console
[root@server ~]# systemctl enable --now openvpn@server

[root@server ~]# ip -c a show tap0
5: tap0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 100
    link/ether 5e:70:c6:f1:48:75 brd ff:ff:ff:ff:ff:ff
    inet 10.10.10.1/24 brd 10.10.10.255 scope global tap0
       valid_lft forever preferred_lft forever
    inet6 fe80::5c70:c6ff:fef1:4875/64 scope link 
       valid_lft forever preferred_lft forever

```


Теперь клиент:  

```console
[root@client ~]# yum -y install epel-release
[root@client ~]# yum install -y openvpn iperf3 policycoreutils-python
```

Конфиг клиента:  

```console
dev tap
proto udp
remote 192.168.10.1

ifconfig 10.10.10.2 255.255.255.0
topology subnet
route 192.168.10.0 255.255.255.252

secret /etc/openvpn/static.key

status /var/log/openvpn-status.log
log /var/log/openvpn.log
verb 3

```

Запускаем клиента (не забыв скопировать static.key): 

```console
[root@client ~]# systemctl enable --now openvpn@server
```

Проверяем подключение:

```console
[root@client ~]# cat /var/log/openvpn-status.log 
OpenVPN STATISTICS
Updated,Sun Nov 17 08:48:03 2019
TUN/TAP read bytes,0
TUN/TAP write bytes,0
TCP/UDP read bytes,0
TCP/UDP write bytes,0
Auth read bytes,0
END

[root@client ~]# ip r | grep tap
10.10.10.0/24 dev tap0 proto kernel scope link src 10.10.10.2 
```

Замеряем скорость: 

```console
[root@server ~]# iperf3 -s
-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
Accepted connection from 10.10.10.2, port 38196
[  5] local 10.10.10.1 port 5201 connected to 10.10.10.2 port 38198
[ ID] Interval           Transfer     Bandwidth
[  5]   0.00-1.00   sec  18.5 MBytes   155 Mbits/sec                  
[  5]   1.00-2.01   sec  20.0 MBytes   167 Mbits/sec                  
[  5]   2.01-3.00   sec  19.5 MBytes   165 Mbits/sec                  
[  5]   3.00-4.01   sec  20.1 MBytes   168 Mbits/sec                  
[  5]   4.01-5.01   sec  20.1 MBytes   168 Mbits/sec                  
[  5]   5.01-6.00   sec  19.6 MBytes   165 Mbits/sec                  
[  5]   6.00-7.00   sec  19.6 MBytes   164 Mbits/sec                  
[  5]   7.00-8.00   sec  19.7 MBytes   165 Mbits/sec                  
[  5]   8.00-9.01   sec  20.3 MBytes   169 Mbits/sec                  
[  5]   9.01-10.01  sec  19.8 MBytes   167 Mbits/sec                  
[  5]  10.01-11.00  sec  19.5 MBytes   164 Mbits/sec                  
[  5]  11.00-12.00  sec  20.2 MBytes   169 Mbits/sec                  
[  5]  12.00-13.00  sec  19.5 MBytes   163 Mbits/sec                  
[  5]  13.00-14.00  sec  19.8 MBytes   167 Mbits/sec                  
[  5]  14.00-15.00  sec  20.3 MBytes   170 Mbits/sec                  
[  5]  15.00-16.00  sec  19.9 MBytes   168 Mbits/sec                  
[  5]  16.00-17.00  sec  20.0 MBytes   167 Mbits/sec                  
[  5]  17.00-18.00  sec  19.6 MBytes   164 Mbits/sec                  
[  5]  18.00-19.01  sec  19.9 MBytes   166 Mbits/sec                  
[  5]  19.01-20.00  sec  19.0 MBytes   160 Mbits/sec                  
[  5]  20.00-21.01  sec  20.1 MBytes   168 Mbits/sec                  
[  5]  21.01-22.00  sec  19.4 MBytes   163 Mbits/sec                  
[  5]  22.00-23.00  sec  19.1 MBytes   160 Mbits/sec                  
[  5]  23.00-24.01  sec  19.5 MBytes   163 Mbits/sec                  
[  5]  24.01-25.00  sec  19.5 MBytes   164 Mbits/sec                  
[  5]  25.00-26.01  sec  19.4 MBytes   162 Mbits/sec                  
[  5]  26.01-27.00  sec  20.0 MBytes   168 Mbits/sec                  
[  5]  27.00-28.00  sec  20.1 MBytes   169 Mbits/sec                  
[  5]  28.00-29.01  sec  19.4 MBytes   162 Mbits/sec                  
[  5]  29.01-30.00  sec  20.3 MBytes   171 Mbits/sec                  
[  5]  30.00-31.00  sec  20.2 MBytes   169 Mbits/sec                  
[  5]  31.00-32.00  sec  20.4 MBytes   171 Mbits/sec                  
[  5]  32.00-33.00  sec  19.7 MBytes   165 Mbits/sec                  
[  5]  33.00-34.00  sec  20.2 MBytes   170 Mbits/sec                  
[  5]  34.00-35.01  sec  19.2 MBytes   160 Mbits/sec                  
[  5]  35.01-36.01  sec  20.5 MBytes   172 Mbits/sec                  
[  5]  36.01-37.00  sec  19.3 MBytes   162 Mbits/sec                  
[  5]  37.00-38.00  sec  19.7 MBytes   165 Mbits/sec                  
[  5]  38.00-39.01  sec  20.0 MBytes   167 Mbits/sec                  
[  5]  39.01-40.01  sec  20.3 MBytes   170 Mbits/sec                  
[  5]  40.01-40.07  sec  1021 KBytes   144 Mbits/sec                  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth
[  5]   0.00-40.07  sec  0.00 Bytes  0.00 bits/sec                  sender
[  5]   0.00-40.07  sec   792 MBytes   166 Mbits/sec                  receiver



[root@client ~]# iperf3 -c 10.10.10.1 -t 40 -i 5
Connecting to host 10.10.10.1, port 5201
[  4] local 10.10.10.2 port 38198 connected to 10.10.10.1 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-5.00   sec  99.8 MBytes   167 Mbits/sec  122    327 KBytes       
[  4]   5.00-10.00  sec  99.1 MBytes   166 Mbits/sec  138    216 KBytes       
[  4]  10.00-15.01  sec  99.8 MBytes   167 Mbits/sec   67    267 KBytes       
[  4]  15.01-20.01  sec  98.0 MBytes   164 Mbits/sec  138    152 KBytes       
[  4]  20.01-25.00  sec  97.5 MBytes   164 Mbits/sec  195    191 KBytes       
[  4]  25.00-30.00  sec  99.0 MBytes   166 Mbits/sec   14    324 KBytes       
[  4]  30.00-35.00  sec   100 MBytes   168 Mbits/sec   51    172 KBytes       
[  4]  35.00-40.00  sec  99.6 MBytes   167 Mbits/sec  137    262 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-40.00  sec   793 MBytes   166 Mbits/sec  862             sender
[  4]   0.00-40.00  sec   792 MBytes   166 Mbits/sec                  receiver

iperf Done.

```


Меняем режим работы на tun и повторно запускаем тесты:   


```console
[root@client ~]# ip -c a s dev tun0
7: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 100
    link/none 
    inet 10.10.10.2/24 brd 10.10.10.255 scope global tun0
       valid_lft forever preferred_lft forever
    inet6 fe80::6da2:c0c0:7eaf:26fe/64 scope link flags 800 
       valid_lft forever preferred_lft forever


[root@server ~]# iperf3 -s                       
-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
Accepted connection from 10.10.10.2, port 38200
[  5] local 10.10.10.1 port 5201 connected to 10.10.10.2 port 38202
[ ID] Interval           Transfer     Bandwidth
[  5]   0.00-1.00   sec  18.8 MBytes   158 Mbits/sec                  
[  5]   1.00-2.00   sec  20.5 MBytes   172 Mbits/sec                  
[  5]   2.00-3.00   sec  20.3 MBytes   171 Mbits/sec                  
[  5]   3.00-4.01   sec  20.6 MBytes   172 Mbits/sec                  
[  5]   4.01-5.00   sec  19.9 MBytes   168 Mbits/sec                  
[  5]   5.00-6.00   sec  20.0 MBytes   168 Mbits/sec                  
[  5]   6.00-7.00   sec  20.3 MBytes   170 Mbits/sec                  
[  5]   7.00-8.00   sec  20.0 MBytes   168 Mbits/sec                  
[  5]   8.00-9.01   sec  20.2 MBytes   168 Mbits/sec                  
[  5]   9.01-10.01  sec  20.3 MBytes   170 Mbits/sec                  
[  5]  10.01-11.00  sec  20.0 MBytes   169 Mbits/sec                  
[  5]  11.00-12.00  sec  17.1 MBytes   144 Mbits/sec                  
[  5]  12.00-13.00  sec  19.8 MBytes   166 Mbits/sec                  
[  5]  13.00-14.00  sec  19.5 MBytes   164 Mbits/sec                  
[  5]  14.00-15.00  sec  19.7 MBytes   165 Mbits/sec                  
[  5]  15.00-16.01  sec  20.4 MBytes   171 Mbits/sec                  
[  5]  16.01-17.01  sec  20.1 MBytes   169 Mbits/sec                  
[  5]  17.01-18.01  sec  20.6 MBytes   173 Mbits/sec                  
[  5]  18.01-19.00  sec  19.9 MBytes   168 Mbits/sec                  
[  5]  19.00-20.01  sec  20.6 MBytes   171 Mbits/sec                  
[  5]  20.01-21.01  sec  20.1 MBytes   169 Mbits/sec                  
[  5]  21.01-22.00  sec  19.8 MBytes   168 Mbits/sec                  
[  5]  22.00-23.01  sec  20.1 MBytes   167 Mbits/sec                  
[  5]  23.01-24.00  sec  20.3 MBytes   171 Mbits/sec                  
[  5]  24.00-25.00  sec  19.9 MBytes   167 Mbits/sec                  
[  5]  25.00-26.00  sec  20.1 MBytes   168 Mbits/sec                  
[  5]  26.00-27.00  sec  19.9 MBytes   167 Mbits/sec                  
[  5]  27.00-28.00  sec  19.6 MBytes   165 Mbits/sec                  
[  5]  28.00-29.00  sec  19.5 MBytes   164 Mbits/sec                  
[  5]  29.00-30.00  sec  20.0 MBytes   168 Mbits/sec                  
[  5]  30.00-31.00  sec  20.0 MBytes   168 Mbits/sec                  
[  5]  31.00-32.01  sec  20.0 MBytes   167 Mbits/sec                  
[  5]  32.01-33.01  sec  19.6 MBytes   165 Mbits/sec                  
[  5]  33.01-34.00  sec  19.9 MBytes   168 Mbits/sec                  
[  5]  34.00-35.00  sec  19.4 MBytes   163 Mbits/sec                  
[  5]  35.00-36.01  sec  19.9 MBytes   166 Mbits/sec                  
[  5]  36.01-37.01  sec  19.2 MBytes   162 Mbits/sec                  
[  5]  37.01-38.01  sec  19.9 MBytes   167 Mbits/sec                  
[  5]  38.01-39.01  sec  19.9 MBytes   167 Mbits/sec                  
[  5]  39.01-40.01  sec  20.4 MBytes   171 Mbits/sec                  
[  5]  40.01-40.06  sec  1.09 MBytes   165 Mbits/sec                  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth
[  5]   0.00-40.06  sec  0.00 Bytes  0.00 bits/sec                  sender
[  5]   0.00-40.06  sec   798 MBytes   167 Mbits/sec                  receiver




[root@client ~]# iperf3 -c 10.10.10.1 -t 40 -i 5
Connecting to host 10.10.10.1, port 5201
[  4] local 10.10.10.2 port 38202 connected to 10.10.10.1 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-5.01   sec   102 MBytes   172 Mbits/sec  224    311 KBytes       
[  4]   5.01-10.00  sec   101 MBytes   170 Mbits/sec  243    275 KBytes       
[  4]  10.00-15.01  sec  96.2 MBytes   161 Mbits/sec  286    184 KBytes       
[  4]  15.01-20.01  sec   101 MBytes   170 Mbits/sec    1    336 KBytes       
[  4]  20.01-25.01  sec   100 MBytes   169 Mbits/sec  324    278 KBytes       
[  4]  25.01-30.01  sec  99.2 MBytes   166 Mbits/sec  142    312 KBytes       
[  4]  30.01-35.00  sec  98.9 MBytes   166 Mbits/sec  145    179 KBytes       
[  4]  35.00-40.00  sec  98.9 MBytes   166 Mbits/sec   18    353 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-40.00  sec   798 MBytes   167 Mbits/sec  1383             sender
[  4]   0.00-40.00  sec   798 MBytes   167 Mbits/sec                  receiver

iperf Done.

```

Выводы: 
- На тестовом стенде это заметно не сильно, но TAP реализация работает медленней чем TUN. Происходит это потому что добавляются L2 заголовки, соотвественно больше накладных расходов.
- На практике чаще всего используется L3 TUN вариант, но если нужно объединить несколько ethernet сегментов, то можно использовать TAP, в таком случае будет что-то вроде L2 коммутатора.

### RAS

