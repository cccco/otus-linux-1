# NFS

Задание:  

- vagrant up должен поднимать 2 виртуалки: сервер и клиент
- на сервер должна быть расшарена директория
- на клиента она должна автоматически монтироваться при старте (fstab или autofs)
- в шаре должна быть папка upload с правами на запись
- требования для NFS: NFSv3 по UDP, включенный firewall

---

### Запуск

Реализовано в виде ролей ansible.  

Для запуска: 

```console
vagrant up
```

### Проверки


Смотрим состояние на клиенте:  

```console
[vagrant@nfsclient ~]$ mount -t nfs
nfsserver:/var/nfs on /mnt/nfs type nfs (rw,relatime,vers=3,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,timeo=14,retrans=2,sec=sys,mountaddr=192.168.56.10,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,addr=192.168.56.10)

[vagrant@nfsclient ~]$ showmount -e nfsserver
Export list for nfsserver:
/var/nfs nfsclient

```
Видим, что используется версия 3 и протокол UDP. 


Теперь попробуем записать файл от обычного пользователя: 

```console
[vagrant@nfsclient ~]$ touch /mnt/nfs/upload/file
[vagrant@nfsclient ~]$ ls -l /mnt/nfs/upload/
total 0
-rw-rw-r--. 1 vagrant vagrant 0 Dec 24 13:50 file

```

И на стороне сервера:  

```console
[vagrant@nfsserver ~]$ ls -l /var/nfs/upload/
total 0
-rw-rw-r--. 1 vagrant vagrant 0 Dec 24 13:50 file

```

Правила firewalld: 

```console
[root@nfsserver ~]# firewall-cmd --state
running
[root@nfsserver ~]# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0 eth1
  sources: 
  services: ssh dhcpv6-client nfs mountd rpc-bind
  ports: 
  protocols: 
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
	

```


