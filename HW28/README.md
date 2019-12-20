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

Устанавливаются следующие веб-фреймворки: 

- php-fpm/laravel
- uwsgi/django
- nodejs/reactjs

Проверить можно обратившись по следующим адресам: 

php-fpm/laravel - http://192.168.56.10:8081 и http://192.168.56.10:8081/otus 

uwsgi/django - http://192.168.56.10:8082  

nodejs/reactjs - http://192.168.56.10:8083  


И php-fpm и uwsgi работают в качестве systemd юнитов и общаются с nginx через unix-сокеты. 


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

Проверяем работу uwsgi в режиме emperor:  

```console
[root@dynamicweb ~]# systemctl status uwsgi
● uwsgi.service - uWSGI Emperor service
   Loaded: loaded (/etc/systemd/system/uwsgi.service; enabled; vendor preset: disabled)
   Active: active (running) since Fri 2019-12-20 13:22:47 UTC; 23min ago
 Main PID: 11308 (uwsgi)
   Status: "The Emperor is governing 1 vassals"
   CGroup: /system.slice/uwsgi.service
           ├─11308 /usr/bin/uwsgi --emperor /etc/uwsgi/sites
           ├─11310 /usr/bin/uwsgi --ini otus.ini
           ├─11361 /usr/bin/uwsgi --ini otus.ini
           ├─11362 /usr/bin/uwsgi --ini otus.ini
           ├─11363 /usr/bin/uwsgi --ini otus.ini
           ├─11364 /usr/bin/uwsgi --ini otus.ini
           └─11365 /usr/bin/uwsgi --ini otus.ini

Dec 20 13:22:48 dynamicweb uwsgi[11308]: Fri Dec 20 13:22:48 2019 - [emperor] vassal otus.ini is ...ests
Dec 20 13:23:33 dynamicweb uwsgi[11308]: [pid: 11363|app: 0|req: 1/1] 192.168.56.1 () {44 vars in...e 0)
Dec 20 13:23:33 dynamicweb uwsgi[11308]: announcing my loyalty to the Emperor...

```


