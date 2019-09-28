# Docker

Задание:
1. Создайте свой кастомный образ nginx на базе alpine. 
1. После запуска nginx должен отдавать кастомную страницу (достаточно изменить дефолтную страницу nginx)
1. Собранный образ необходимо запушить в docker hub и дать ссылку на ваш репозиторий.   
1. Определите разницу между контейнером и образом 
1. Можно ли в контейнере собрать ядро? 
1. Создайте кастомные образы nginx и php, объедините их в docker-compose. После запуска nginx должен показывать php info.  

---

### Кастомный образ на базе alpine

Для того чтобы запушить в docker hub: 

```console

[root@localhost ~]# docker login
Username: sinist3r
Password: 
Login Succeeded

[root@localhost ~]# docker push sinist3r/alpine-nginx

```

Запустить контейнер: 

```console
[root@localhost ~]# docker run -d -p 8080:80 sinist3r/alpine-nginx:1.5

[root@localhost ~]# curl http://127.0.0.1:8080/
<!DOCTYPE html>
<html>
<head>
<title>Welcome to docker OTUS!</title>
...

```


Полезные материалы:  
- https://www.linuxnix.com/how-to-push-docker-images-to-docker-hub-repository/
- https://github.com/nginxinc/docker-nginx

### В чем разница между контейнером и образом?

![dockers](https://github.com/sinist3rr/otus-linux/blob/master/HW13/images/dockers.png)

Образы похожи на замороженные снапшоты контейнеров. 
Образ обычно содержит объединение нескольких слоев файловых систем. Образ не имеет состояния и никогда не меняется.  
Контейнер в свою очередь - это своего рода экземпляр образа. Важно, что при запуске контейнера создается слой файловой системы с возможностью чтения/записи.   

### Можно ли в контейнере собрать ядро?

Можно собрать ядро, можно скомпилировать любое другое приложение, так же можно собирать пакеты.  
[Например docker-kernel-builder](https://github.com/moul/docker-kernel-builder). 

### Docker-compose nginx и php

Для этого был собран еще один кастомный контейнер `sinist3r/alpine-php`.

Чтобы запустить весь стек:

```console

[root@localhost ~]# cd alpine-www/
[root@localhost alpine-www]# docker-compose up -d

```

Проверка результата:

```console

[root@localhost ~]# curl http://127.0.0.1:8080
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "DTD/xhtml1-transitional.dtd">
...
<title>PHP 7.3.9 - phpinfo()</title><meta name="ROBOTS" content="NOINDEX,NOFOLLOW,NOARCHIVE" /></head>
...

```

![docker-compose](https://github.com/sinist3rr/otus-linux/blob/master/HW13/images/docker-compose-works.png)

Полезные материалы:  
- https://stackoverflow.com/questions/15423500/nginx-showing-blank-php-pages
- https://www.nginx.com/resources/wiki/start/topics/examples/phpfcgi/

