# SELinux 

Задание:  
-
---

### Практика по SELinux 

Сразу установим недостающий софт: 

```console
[root@localhost ~]# yum -y install policycoreutils-python setroubleshoot
```

Имеем установленный apache: 

```console
[root@localhost ~]# systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
   Active: active (running) since Fri 2019-09-13 06:05:17 UTC; 6s ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 4276 (httpd)
   Status: "Processing requests..."
   CGroup: /system.slice/httpd.service
           ├─4276 /usr/sbin/httpd -DFOREGROUND
           ├─4277 /usr/sbin/httpd -DFOREGROUND
           ├─4278 /usr/sbin/httpd -DFOREGROUND
           ├─4279 /usr/sbin/httpd -DFOREGROUND
           ├─4280 /usr/sbin/httpd -DFOREGROUND
           └─4281 /usr/sbin/httpd -DFOREGROUND
```

Проверяем работу веб сервера: 

```console
[root@localhost ~]# echo 'this is my default directory' > /var/www/html/index.txt

[root@localhost ~]# curl http://10.0.2.15/index.txt
this is my default directory
```

Видим, что всё работает.  

Теперь представим ситуацию, что на веб сервере необходимо разместить новое приложение. 

```console
[root@localhost ~]# mkdir /var/webapp
[root@localhost ~]# echo 'this is my webapp directory' > /var/webapp/index.txt

[root@localhost ~]# sed -i 's/www\/html/webapp/' /etc/httpd/conf/httpd.conf
[root@localhost ~]# systemctl restart httpd
```

Проверяем и видим сообщение об ошибке: 

```console
[root@localhost ~]# curl http://10.0.2.15/index.txt
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>403 Forbidden</title>
</head><body>
<h1>Forbidden</h1>
<p>You don't have permission to access /index.txt
on this server.</p>
</body></html>
```

Изучаем логи: 

```console
[root@localhost ~]# tail /var/log/httpd/error_log
[Fri Sep 13 06:09:10.397031 2019] [core:error] [pid 4322] (13)Permission denied: [client 10.0.2.15:33746] AH00035: access to /index.txt denied (filesystem path '/var/webapp/index.txt') because search permissions are missing on a component of the path
```

Проверяем и сравниваем контекст: 

```console
[root@localhost ~]# ll -Z /var/www/html/index.txt
-rw-r--r--. root root unconfined_u:object_r:httpd_sys_content_t:s0 /var/www/html/index.txt
[root@localhost ~]# ll -Z /var/webapp/index.txt
-rw-r--r--. root root unconfined_u:object_r:var_t:s0   /var/webapp/index.txt
```

SELinux не дает читать файлы которые имеют тип var_t.    

Существует несколько вариантов исправить ситуацию, рассмотрим их один за другим.   

Первый вариант изменить контекст на объекте:   

```console
[root@localhost ~]# chcon -R --type=httpd_sys_content_t /var/webapp/
[root@localhost ~]# ll -Z /var/webapp/index.txt
-rw-r--r--. root root unconfined_u:object_r:httpd_sys_content_t:s0 /var/webapp/index.txt
```
Проверяем: 

```console
[root@localhost ~]# curl http://10.0.2.15/index.txt
this is my webapp directory
```

Заработало, но это может быть не очень удобно и оптимально.  


Тем временем у нас появилось другое веб приложение, подготовим среду:  

```console
[root@localhost ~]# mkdir /var/webapp2
[root@localhost ~]# echo 'this is my second webapp page' > /var/webapp2/index.txt
[root@localhost ~]# sed -i 's/webapp/webapp2/' /etc/httpd/conf/httpd.conf
[root@localhost ~]# systemctl restart httpd
```


Проверяем:  

```console
[root@localhost ~]# curl http://10.0.2.15/index.txt
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>403 Forbidden</title>
</head><body>
<h1>Forbidden</h1>
<p>You don't have permission to access /index.txt
on this server.</p>
</body></html>
```

Опять не работает. 

Ситуация выглядит как:  

```console
[root@localhost ~]# ll -Z /var/
drwxr-xr-x. root root unconfined_u:object_r:httpd_sys_content_t:s0 webapp
drwxr-xr-x. root root unconfined_u:object_r:var_t:s0   webapp2
drwxr-xr-x. root root system_u:object_r:httpd_sys_content_t:s0 www
```


Создаем новый контекст:  

```console
[root@localhost ~]# semanage fcontext -a -t httpd_sys_content_t "/var/webapp2(/.*)?"
```

Проверяем что он появился:  

```console
[root@localhost ~]# grep webapp2 /etc/selinux/targeted/contexts/files/file_contexts.local
/var/webapp2(/.*)?    system_u:object_r:httpd_sys_content_t:s0
```


Но при этом ничего не поменялось:  

```console
[root@localhost ~]# ll -Z /var/
drwxr-xr-x. root root unconfined_u:object_r:httpd_sys_content_t:s0 webapp
drwxr-xr-x. root root unconfined_u:object_r:var_t:s0   webapp2
drwxr-xr-x. root root system_u:object_r:httpd_sys_content_t:s0 www
```

Мы определили новый контекст, но чтобы он применился можно сделать сброс до дефолта: 

```console
[root@localhost ~]# restorecon -R -v /var/webapp2
restorecon reset /var/webapp2 context unconfined_u:object_r:var_t:s0->unconfined_u:object_r:httpd_sys_content_t:s0
restorecon reset /var/webapp2/index.txt context unconfined_u:object_r:var_t:s0->unconfined_u:object_r:httpd_sys_content_t:s0
```
И проверяем: 

```console
[root@localhost ~]# curl http://10.0.2.15/index.txt
this is my second webapp page
```
Ну и третий способ:  

```console
[root@localhost ~]# mkdir /var/webapp3
[root@localhost ~]# echo 'this is my third webapp page' > /var/webapp3/index.txt      
[root@localhost ~]# sed -i 's/webapp2/webapp3/' /etc/httpd/conf/httpd.conf 
[root@localhost ~]# systemctl restart httpd
```

Для начала очистим лог, чтобы не мешали предыдущие события selinux: 

```console
[root@localhost ~]# > /var/log/audit/audit.log
```

Отключим временно selinux (это полезно в некоторых случаях чтобы собрать все события и собрать рабочий модуль):  

```console
[root@localhost ~]# getenforce 
Enforcing
[root@localhost ~]# setenforce 0
[root@localhost ~]# getenforce  
Permissive
```
И теперь обратимся в веб приложению: 

```console
[root@localhost ~]# curl http://10.0.2.15/index.txt
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>403 Forbidden</title>
</head><body>
<h1>Forbidden</h1>
<p>You don't have permission to access /index.txt
on this server.</p>
</body></html>
```
Включаем selinux обратно: 

```console
[root@localhost ~]# setenforce 1
[root@localhost ~]# getenforce                                              
Enforcing
```

Смотрим еще один инструмент траблшутинга: 

```console
[root@localhost ~]# ausearch -if /var/log/audit/audit.log -m AVC | audit2why
type=AVC msg=audit(1568357972.549:857): avc:  denied  { getattr } for  pid=5047 comm="httpd" path="/var/webapp3/index.txt" dev="sda1" ino=670538 scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:var_t:s0 tclass=file permissive=0

        Was caused by:
                Missing type enforcement (TE) allow rule.

                You can use audit2allow to generate a loadable module to allow this access.

type=AVC msg=audit(1568357972.549:858): avc:  denied  { getattr } for  pid=5047 comm="httpd" path="/var/webapp3/index.txt" dev="sda1" ino=670538 scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:var_t:s0 tclass=file permissive=0

        Was caused by:
                Missing type enforcement (TE) allow rule.

                You can use audit2allow to generate a loadable module to allow this access.
```

Создаем модуль на основе сообщений лог файла: 

```console
[root@localhost ~]# audit2allow -M http_dir --debug < /var/log/audit/audit.log
******************** IMPORTANT ***********************
To make this policy package active, execute:
```

Включаем свежесозданный модуль:  

```console
[root@localhost ~]# semodule -i http_dir.pp 
```

И проверяем результат: 

```console
[root@localhost ~]# curl http://10.0.2.15/index.txt                         
this is my third webapp page
```

Файлы лежат в текущем каталоге: 

```console
[root@localhost ~]# ls http_dir.*
http_dir.pp  http_dir.te
```
Следует понимать, что автоматизированные инструменты зачастую делают более широкие привилегии чем это нужно: 

```console
[root@localhost ~]# cat http_dir.te 

module http_dir 1.0;

require {
        type httpd_t;
        type var_t;
        class file { getattr open read };
}

#============= httpd_t ==============

#!!!! WARNING: 'var_t' is a base type.
allow httpd_t var_t:file { getattr open read };
```

