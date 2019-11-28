# NGINX

Задание:  

Написать конфигурацию nginx, которая даёт доступ клиенту только с определенной cookie.  
Если у клиента её нет, нужно выполнить редирект на location, в котором кука будет добавлена, после чего клиент будет обратно отправлен (редирект) на запрашиваемый ресурс.

---

### Запуск

Реализовано в виде роли ansible.   

Для запуска: 

```console
vagrant up
```

### NGINX

В итоге получилась следующая конфигурация: 

```

    location / {
        if ($http_cookie !~* "secret=s3cr3t1") {
            return 302 http://$http_host/setc;
        }

            ~~try_files $uri /index.html index.php;~~
    }
        

    location /setc {
        add_header Set-Cookie "secret=s3cr3t1";
        ~~return 302 http://$http_host;~~
        return 302 http://$http_host$request_uri;
    }

```

Проверяем работу на хост машине:  


```console
┌─[sinister@desk]─[~/otus-linux/HW22]
└──╼ $curl -I http://192.168.56.10
HTTP/1.1 302 Moved Temporarily
Server: nginx/1.16.1
Date: Wed, 20 Nov 2019 13:28:47 GMT
Content-Type: text/html
Content-Length: 145
Connection: keep-alive
Location: http://192.168.56.10/setc


┌─[sinister@desk]─[~/otus-linux/HW22]
└──╼ $curl -I --cookie "secret=s3cr3t1" http://192.168.56.10
HTTP/1.1 200 OK
Server: nginx/1.16.1
Date: Wed, 20 Nov 2019 13:29:53 GMT
Content-Type: text/html
Content-Length: 4833
Last-Modified: Fri, 16 May 2014 15:12:48 GMT
Connection: keep-alive
ETag: "53762af0-12e1"
Accept-Ranges: bytes

```

В браузере: 
![nginx](https://github.com/sinist3rr/otus-linux/blob/master/HW22/images/nginx1.png)

