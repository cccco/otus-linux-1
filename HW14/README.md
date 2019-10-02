# Logging

Задание:  
Настраиваем центральный сервер для сбора логов   
В вагранте поднимаем 2 машины web и log:    
На web поднимаем nginx    
На log настраиваем центральный лог сервер на любой системе на выбор:    
- journald
- rsyslog
- elk

Настраиваем аудит следящий за изменением конфигов nginx  
Все критичные логи с web должны собираться и локально и удаленно   
Все логи с nginx должны уходить на удаленный сервер (локально только критичные)   
Логи аудита должны также уходить на удаленную систему   

* Развернуть еще машину ELK   

---

### Был выбран rsyslog 

Для запуска: 

```console
vagrant up
```

**Примечание**: 
`RUNNING HANDLER [web : restart auditd] **` может выполняться достаточно долго, всё еще неисправленный баг в ansible и SaltStack. 

Проверяем логирование системных событий:  

```console
[root@web ~]# logger -p crit test critical error
[root@web ~]# tail /var/log/messages
Oct  2 13:09:39 web vagrant: test critical error

[root@log ~]# tail /var/log/web/vagrant.log 
Oct  2 13:09:39 web vagrant: test critical error
```

Проверяем логирование nginx:

```console
[root@log ~]# curl -I http://192.168.56.10
HTTP/1.1 200 OK
[root@log ~]# curl -I http://192.168.56.10/not
HTTP/1.1 404 Not Found

[root@log ~]# tail /var/log/web/nginx.log 
Oct  2 13:13:02 web nginx: 192.168.56.11 - - [02/Oct/2019:13:13:02 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/7.29.0" "-"
Oct  2 13:13:44 web nginx: 2019/10/02 13:13:44 [error] 6255#0: *2 open() "/usr/share/nginx/html/not" failed (2: No such file or directory), client: 192.168.56.11, server: _, request: "HEAD /not HTTP/1.1", host: "192.168.56.10"
Oct  2 13:13:44 web nginx: 192.168.56.11 - - [02/Oct/2019:13:13:44 +0000] "HEAD /not HTTP/1.1" 404 0 "-" "curl/7.29.0" "-"

```

Проверяем логи auditd:

```console
[root@web ~]# vi /etc/nginx/nginx.conf
[root@web ~]# ausearch -i -k nginx_config_change
type=PROCTITLE msg=audit(10/02/2019 14:21:59.495:3956) : proctitle=vi /etc/nginx/nginx.conf
...

[root@log ~]# ausearch -i -k nginx_config_change
node=web type=PROCTITLE msg=audit(10/02/2019 14:21:59.495:3956) : proctitle=vi /etc/nginx/nginx.conf
...

```

Полезные материалы:  
- https://www.the-art-of-web.com/system/rsyslog-config/
- https://docs.nginx.com/nginx/admin-guide/monitoring/logging/
- https://www.server-world.info/en/note?os=CentOS_7&p=audit&f=2
- https://stackoverflow.com/questions/41053331/ansible-how-to-restart-auditd-service-on-centos-7-get-error-about-dependency

