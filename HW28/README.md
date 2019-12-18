# Dynamic web

Задание:  
Собрать стенд с 3мя проектами на выбор  
nginx + php-fpm (laravel/wordpress) + python (flask/django) + js(react/angular)   

---

### Запуск

Реализовано в виде ролей ansible.  

Для запуска: 

```console
vagrant up
```

### Проверки


Проверяем работу php-fpm	

```console
[root@dynamicweb ~]# systemctl status php-fpm
● php-fpm.service - The PHP FastCGI Process Manager
   Loaded: loaded (/usr/lib/systemd/system/php-fpm.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2019-12-18 14:43:24 UTC; 2min 14s ago
 Main PID: 8092 (php-fpm)
   Status: "Processes active: 0, idle: 5, Requests: 1, slow: 0, Traffic: 0req/sec"
   CGroup: /system.slice/php-fpm.service
           ├─8092 php-fpm: master process (/etc/php-fpm.conf)
           ├─8094 php-fpm: pool www
           ├─8095 php-fpm: pool www
           ├─8096 php-fpm: pool www
           ├─8097 php-fpm: pool www
           └─8098 php-fpm: pool www

Dec 18 14:43:24 dynamicweb systemd[1]: Starting The PHP FastCGI Process Manager...
Dec 18 14:43:24 dynamicweb systemd[1]: Started The PHP FastCGI Process Manager.

```

http://192.168.56.10:8081/helloworld

