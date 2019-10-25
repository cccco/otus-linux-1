# Iptables

Задание:  
1) реализовать knocking port
- centralRouter может попасть на ssh inetRouter через knock скрипт 
2) добавить inetRouter2, который виден(маршрутизируется) с хоста 
3) запустить nginx на centralServer 
4) пробросить 80й порт на inetRouter2 8080 
5) дефолт в инет оставить через inetRouter  

---

### Топология

![network](https://github.com/sinist3rr/otus-linux/blob/master/HW17/images/net1.png)


### Port knocking

Реализовано только средствами iptables:

```
*filter
:INPUT DROP [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:TRAFFIC - [0:0]
:SSH-INPUT - [0:0]
:SSH-INPUTTWO - [0:0]
# TRAFFIC chain for Port Knocking. The correct port sequence in this example is  8881 -> 7777 -> 9991; any other sequence will drop the traffic 
-A INPUT -j TRAFFIC
-A TRAFFIC -p icmp --icmp-type any -j ACCEPT
-A TRAFFIC -m state --state ESTABLISHED,RELATED -j ACCEPT
-A TRAFFIC -m state --state NEW -m tcp -p tcp --dport 22 -m recent --rcheck --seconds 30 --name SSH2 -j ACCEPT
-A TRAFFIC -m state --state NEW -m tcp -p tcp -m recent --name SSH2 --remove -j DROP
-A TRAFFIC -m state --state NEW -m tcp -p tcp --dport 9991 -m recent --rcheck --name SSH1 -j SSH-INPUTTWO
-A TRAFFIC -m state --state NEW -m tcp -p tcp -m recent --name SSH1 --remove -j DROP
-A TRAFFIC -m state --state NEW -m tcp -p tcp --dport 7777 -m recent --rcheck --name SSH0 -j SSH-INPUT
-A TRAFFIC -m state --state NEW -m tcp -p tcp -m recent --name SSH0 --remove -j DROP
-A TRAFFIC -m state --state NEW -m tcp -p tcp --dport 8881 -m recent --name SSH0 --set -j DROP
-A SSH-INPUT -m recent --name SSH1 --set -j DROP
-A SSH-INPUTTWO -m recent --name SSH2 --set -j DROP 
-A TRAFFIC -j DROP
COMMIT
```

Для запуска: 

```console
vagrant up
```

Пробуем подключаться по ssh на inetRouter: 

```console

[root@centralRouter ~]# ssh -vvv vagrant@192.168.255.1
OpenSSH_7.4p1, OpenSSL 1.0.2k-fips  26 Jan 2017
debug1: Reading configuration data /etc/ssh/ssh_config
debug1: /etc/ssh/ssh_config line 58: Applying options for *
debug2: resolving "192.168.255.1" port 22
debug2: ssh_connect_direct: needpriv 0
debug1: Connecting to 192.168.255.1 [192.168.255.1] port 22.
debug1: connect to address 192.168.255.1 port 22: Connection timed out
ssh: connect to host 192.168.255.1 port 22: Connection timed out

```
Видим, что просто так на ssh подключится не получается. 

Пробуем простучать порты на inetRouter, для этого можно использовать и nmap и специализированную утилиту (knock), но самый простой вариант - это использовать сетевую утилиту **hping**.

```console

[root@centralRouter ~]# hping3 -S 192.168.255.1 -p 8881 -c 1; hping3 -S 192.168.255.1 -p 7777 -c 1; hping3 -S 192.168.255.1 -p 9991 -c 1

```

После простукивания пробуем подключиться еще раз:  

```console

[root@centralRouter ~]# ssh vagrant@192.168.255.1
The authenticity of host '192.168.255.1 (192.168.255.1)' can't be established.
RSA key fingerprint is SHA256:sCe9FyDOdZ8p6yjqMOcT/QRmfZ/Of/mje1AGNmvnHwU.
RSA key fingerprint is MD5:92:63:98:c1:d5:ff:b7:05:be:6a:c5:97:3a:b5:36:04.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '192.168.255.1' (RSA) to the list of known hosts.
vagrant@192.168.255.1's password: 
[vagrant@inetRouter ~]$ 

```

Подключение прошло успешно, port knocking работает. 

### Port forwarding

Для проброса портов vagrant добавляет два правила в iptables:

```console
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 8080 -j DNAT --to-destination 192.168.0.2:80
iptables -t nat -A POSTROUTING ! -s 127.0.0.1 -j MASQUERADE
```
Первое правило непосредственно осуществляет пересылку пакетов приходящих на порт 8080 inetRouter2 в сторону centralServer и его порт 80. 
Второе правило - решает проблему с адресом отправителя, для того чтобы ответ nginx шел не в мир, а на inetRouter2.   

В результате если в браузере обратится на localhost:


![nginx](https://github.com/sinist3rr/otus-linux/blob/master/HW17/images/net2.png)

Видим, что порт пробрасывается. 

