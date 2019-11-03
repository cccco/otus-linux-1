# DNS

Задание:  

взять стенд https://github.com/erlong15/vagrant-bind 
добавить еще один сервер client2 

завести в зоне dns.lab имена: 
- web1 - смотрит на клиент1
- web2 смотрит на клиент2

завести еще одну зону newdns.lab   
завести в ней запись   
www - смотрит на обоих клиентов    

настроить split-dns:
- клиент1 - видит обе зоны, но в зоне dns.lab только web1  
- клиент2 видит только dns.lab 

---

### Запуск


Для запуска: 

```console
vagrant up
```

### Проверяем DNS:


Клиент1 должен видеть обе зоны, но в зоне dns.lab только web1: 

```console
[vagrant@client ~]$ dig www.newdns.lab +short
192.168.50.25
192.168.50.15

[vagrant@client ~]$ dig -x 192.168.50.15 +short
web1.dns.lab.
www.newdns.lab.

[vagrant@client ~]$ dig -x 192.168.50.25 +short
www.newdns.lab.

[vagrant@client ~]$ dig web1.dns.lab +short
192.168.50.15
```

Клиент2 видит только зону dns.lab:   

```console
[vagrant@client2 ~]$ dig -x 192.168.50.15 +short
web1.dns.lab.
[vagrant@client2 ~]$ dig -x 192.168.50.25 +short
web2.dns.lab.

[vagrant@client2 ~]$ dig web1.dns.lab +short
192.168.50.15
[vagrant@client2 ~]$ dig web2.dns.lab +short
192.168.50.25
```

### SELinux

Всего лишь изменил пути для хранения зон:
provisioning/slave-named.conf:

```
    file "slaves/named.dns.lab";
```
После этого слейв начал работать и забирать зоны с мастера в режиме enforced.  

### Примечания

Больше всего времени ушло на решение проблемы с трансфером зоны, слейв упорно отказывался забирать зоны по одному ключу.    
Решилось только созданием второго ключа `dnssec-keygen -a HMAC-MD5 -b 128 -n HOST -r /dev/urandom zonetransfer2.key.` и разнесением ключей по разным view.

Помогли следующие материалы: 

- http://movingpackets.net/2013/06/10/bind-enabling-tsig-for-zone-transfers/
- https://kb.isc.org/docs/aa-00296

