# Работа с Systemd

Задание:  
1. Написать сервис, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова. Файл и слово должны задаваться в /etc/sysconfig 
2. Из epel установить spawn-fcgi и переписать init-скрипт на unit-файл. Имя сервиса должно так же называться. 
3. Дополнить юнит-файл apache httpd возможностью запустить несколько инстансов сервера с разными конфигами 
4. (*) Скачать демо-версию Atlassian Jira и переписать основной скрипт запуска на unit-файл. Задание необходимо сделать с использованием Vagrantfile и proviosioner shell 
---

### 1. Написать сервис, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова 

Сначала создаем конфигурацию для сервиса:


```console
vi /etc/sysconfig/watchlog

# Configuration file for the watchdog service

WORD="ALERT"
LOG=/var/log/watchlog.log

```

Создаем лог файл и заполняем его строками:

```console
touch /var/log/watchlog.log
echo "ALERT something bad happen" >> /var/log/watchlog.log
```

Создаем скрипт, который будет искать слово в логе:

```console
vi /opt/watchlog.sh

#!/bin/bash

WORD=$1
LOG=$2
DATE=`date`

if grep $WORD $LOG &> /dev/null
then
    logger "$DATE: word was found!"
else
    exit 0
fi

chmod +x /opt/watchlog.sh
```

Создаем юнит для сервиса:

```console
vi /etc/systemd/system/watchlog.service
[Unit]
Description=Watchlog service

[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh $WORD $LOG
```

Создаем юнит для таймера:

```console
vi /etc/systemd/system/watchlog.timer

[Unit]
Description=Run watchlog script every 30 seconds

[Timer]
OnActiveSec=0
OnUnitActiveSec=30
AccuracySec=500msec
Unit=watchlog.service

[Install]
WantedBy=multi-user.target
```

Необходимо перечитать юниты, и запустить таймер:

```console
systemctl daemon-reload               
systemctl start watchlog.timer
```

Проверяем результат:

```console
[root@jira ~]# journalctl -f
-- Logs begin at Fri 2019-08-30 12:20:23 UTC. --
Aug 30 12:43:59 jira root[9837]: Fri Aug 30 12:43:59 UTC 2019: word was found!
Aug 30 12:43:59 jira systemd[1]: Started Watchlog service.
Aug 30 12:44:29 jira systemd[1]: Starting Watchlog service...
Aug 30 12:44:29 jira root[9842]: Fri Aug 30 12:44:29 UTC 2019: word was found!
Aug 30 12:44:29 jira systemd[1]: Started Watchlog service.
Aug 30 12:45:00 jira systemd[1]: Starting Watchlog service...
Aug 30 12:45:00 jira root[9846]: Fri Aug 30 12:45:00 UTC 2019: word was found!
Aug 30 12:45:00 jira systemd[1]: Started Watchlog service.
```

### 2. Из epel установить spawn-fcgi и переписать init-скрипт на unit-файл

Устанавливаем все необходимые пакеты:

```console
yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y
```

Вначале правим конфиг, нужно раскоментировать обе строки:

```console
vi /etc/sysconfig/spawn-fcgi

SOCKET=/var/run/php-fcgi.sock
OPTIONS="-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -P /var/run/spawn-fcgi.pid -- /usr/bin/php-cgi"
```

Теперь создаем юнит для сервиса:

```console
vi /etc/systemd/system/spawn-fcgi.service

[Unit]
Description=Spawn-fcgi startup service
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n $OPTIONSKillMode=process

[Install]
WantedBy=multi-user.target
```

Проверяем что сервис запускается:

```console
systemctl daemon-reload
systemctl start spawn-fcgi

[root@jira ~]# systemctl status spawn-fcgi
● spawn-fcgi.service - Spawn-fcgi startup service
   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
   Active: active (running) since Fri 2019-08-30 13:16:47 UTC; 3s ago
 Main PID: 10340 (php-cgi)
   CGroup: /system.slice/spawn-fcgi.service
           ├─10340 /usr/bin/php-cgi
           ├─10341 /usr/bin/php-cgi
           ├─10342 /usr/bin/php-cgi
           ├─10343 /usr/bin/php-cgi
           ├─10344 /usr/bin/php-cgi
           ├─10345 /usr/bin/php-cgi
           ├─10346 /usr/bin/php-cgi
           ├─10347 /usr/bin/php-cgi
           ├─10348 /usr/bin/php-cgi
           ├─10349 /usr/bin/php-cgi
           ├─10350 /usr/bin/php-cgi
           ├─10351 /usr/bin/php-cgi
           ├─10352 /usr/bin/php-cgi
           ├─10353 /usr/bin/php-cgi
           ├─10354 /usr/bin/php-cgi
           ├─10355 /usr/bin/php-cgi
           ├─10356 /usr/bin/php-cgi
           ├─10357 /usr/bin/php-cgi
           ├─10358 /usr/bin/php-cgi
           ├─10359 /usr/bin/php-cgi
           ├─10360 /usr/bin/php-cgi
           ├─10361 /usr/bin/php-cgi
           ├─10362 /usr/bin/php-cgi
           ├─10363 /usr/bin/php-cgi
           ├─10364 /usr/bin/php-cgi
           ├─10365 /usr/bin/php-cgi
           ├─10366 /usr/bin/php-cgi
           ├─10367 /usr/bin/php-cgi
           ├─10368 /usr/bin/php-cgi
           ├─10369 /usr/bin/php-cgi
           ├─10370 /usr/bin/php-cgi
           ├─10371 /usr/bin/php-cgi
           └─10372 /usr/bin/php-cgi

Aug 30 13:16:47 jira systemd[1]: Started Spawn-fcgi startup service.

```

### 3. Дополнить юнит-файл apache httpd возможностью запустить несколько инстансов сервера с разными конфигами

Для того чтобы появилась возможность запускать несколько экземпляров сервиса с различными конфига нужно добавить параметр шаблонизации в юнит файле:

```console
cp /usr/lib/systemd/system/httpd.service /etc/systemd/system/httpd@.service

vi /etc/systemd/system/httpd@.service
EnvironmentFile=/etc/sysconfig/httpd-%I
```

Теперь нужно создать соответствующую конфигурацию:

```console
echo "OPTIONS=-f conf/first.conf" > /etc/sysconfig/httpd-first
echo "OPTIONS=-f conf/second.conf" > /etc/sysconfig/httpd-second
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/first.conf 
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/second.conf 
```

Чтобы смогли запустить оба инстанса нужно чтобы у второго отличались параметры Listen и PidFile:

```console

vi /etc/httpd/conf/second.conf

PidFile /var/run/httpd-second.pid
Listen 8080
```

Проверяем работу:

```console
systemctl daemon-reload
systemctl start httpd@first
systemctl start httpd@second

ss -tulpen | grep httpd
tcp    LISTEN     0      128      :::8080                 :::*                   users:(("httpd",pid=31748,fd=4),("httpd",pid=31747,fd=4),("httpd",pid=31746,fd=4),("httpd",pid=31745,fd=4),("httpd",pid=31744,fd=4),("httpd",pid=31743,fd=4),("httpd",pid=31742,fd=4)) ino:74059 sk:ffff92803696a100 v6only:0 <->
tcp    LISTEN     0      128      :::80                   :::*                   users:(("httpd",pid=31735,fd=4),("httpd",pid=31734,fd=4),("httpd",pid=31733,fd=4),("httpd",pid=31732,fd=4),("httpd",pid=31731,fd=4),("httpd",pid=31730,fd=4),("httpd",pid=31729,fd=4)) ino:73909 sk:ffff9280369698c0 v6only:0 <->
```

### 4. (*) Скачать демо-версию Atlassian Jira и переписать основной скрипт запуска на unit-файл

```console

vagrant up
vagrant ssh

[root@jira ~]# systemctl status jira
● jira.service - JIRA Service
   Loaded: loaded (/etc/systemd/system/jira.service; disabled; vendor preset: disabled)
   Active: active (running) since Sat 2019-08-31 08:43:45 UTC; 13s ago
     Docs: https://community.atlassian.com
  Process: 10585 ExecStart=/opt/atlassian/jira/bin/start-jira.sh (code=exited, status=0/SUCCESS)
 Main PID: 10619 (java)
   CGroup: /system.slice/jira.service
           └─10619 /opt/atlassian/jira/jre//bin/java -Djava.util.logging.config.file=/opt/atlassian/j...

Aug 31 08:43:45 jira start-jira.sh[10585]: MMMMMM
Aug 31 08:43:45 jira start-jira.sh[10585]: +MMMMM
Aug 31 08:43:45 jira start-jira.sh[10585]: MMMMM
Aug 31 08:43:45 jira start-jira.sh[10585]: `UOJ
Aug 31 08:43:45 jira start-jira.sh[10585]: Atlassian Jira
Aug 31 08:43:45 jira start-jira.sh[10585]: Version : 8.3.3
```

![jira](https://github.com/sinist3rr/otus-linux/blob/master/HW08/images/jira_web.png)

