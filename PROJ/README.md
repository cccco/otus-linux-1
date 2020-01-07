# HA Project

Задание:  

В проект должны быть включены:  
— как минимум 2 узла с СУБД;   
— минимум 2 узла с веб-серверами;   
— настройка межсетевого экрана (запрещено всё, что не разрешено);   
— скрипты резервного копирования;   
— центральный сервер сбора логов (Rsyslog/Journald/ELK).  

---

### Запуск

Реализовано в виде ролей ansible.  

Для запуска: 

```console
vagrant up
```

### Проверки

Устанавливается Nextcloud Server.  

Проверить можно обратившись по адресу: 

http://192.168.56.10 

Проверяем работу php-fpm	

```console
[root@nextcloud ~]# systemctl status php-fpm
● php-fpm.service - The PHP FastCGI Process Manager
   Loaded: loaded (/usr/lib/systemd/system/php-fpm.service; enabled; vendor preset: disabled)
   Active: active (running) since Mon 2020-01-06 16:16:35 UTC; 4min 5s ago
 Main PID: 26312 (php-fpm)
   Status: "Processes active: 0, idle: 20, Requests: 0, slow: 0, Traffic: 0req/sec"
   CGroup: /system.slice/php-fpm.service
           ├─26312 php-fpm: master process (/etc/php-fpm.conf)
           ├─26313 php-fpm: pool www
           ├─26314 php-fpm: pool www
           ├─26315 php-fpm: pool www
           ├─26316 php-fpm: pool www
           ├─26317 php-fpm: pool www
           ├─26318 php-fpm: pool www
           ├─26319 php-fpm: pool www
           ├─26320 php-fpm: pool www
           ├─26321 php-fpm: pool www
           ├─26322 php-fpm: pool www
           ├─26323 php-fpm: pool www
           ├─26324 php-fpm: pool www
           ├─26325 php-fpm: pool www
           ├─26326 php-fpm: pool www
           ├─26327 php-fpm: pool www
           ├─26328 php-fpm: pool www
           ├─26329 php-fpm: pool www
           ├─26330 php-fpm: pool www
           ├─26331 php-fpm: pool www
           └─26332 php-fpm: pool www

Jan 06 16:16:35 nextcloud systemd[1]: Stopped The PHP FastCGI Process Manager.
Jan 06 16:16:35 nextcloud systemd[1]: Starting The PHP FastCGI Process Manager...
Jan 06 16:16:35 nextcloud systemd[1]: Started The PHP FastCGI Process Manager.

```

Known issues: 

- `firewall-cmd --list-ports` shows empty (but reload...) 
- selinux blocks php-fpm: 
- `NOTICE: PHP message: PHP Fatal error:  apc_mmap: mkstemp on /tmp/apc.Vh4gUH failed in Unknown on line 0`  
- mariadb need to be replaced by mysql  

