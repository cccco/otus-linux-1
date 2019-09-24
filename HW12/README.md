# Резервное копирование

Задание:  
Настроить стенд Vagrant с двумя виртуальными машинами server и client. 

Настроить политику бэкапа директории /etc с клиента: 
1) Полный бэкап - раз в день 
2) Инкрементальный - каждые 10 минут 
3) Дифференциальный - каждые 30 минут 

Запустить систему на два часа. Для сдачи ДЗ приложить list jobs, list files jobid=<id>
и сами конфиги bacula 

---

### Bacula 

Для запуска:

```console
vagrant up
```

Результаты после двух часов работы:  

```
list jobs
```
![bacula1](https://github.com/sinist3rr/otus-linux/blob/master/HW12/images/bacula1.png)


```
lits files jobid=19
```

![bacula2](https://github.com/sinist3rr/otus-linux/blob/master/HW12/images/bacula2.png)

[list files jobid=19](https://github.com/sinist3rr/otus-linux/blob/master/HW12/jobid19.log) (Full)


Полезные материалы:  
- https://github.com/tyler-hitzeman/bacula/blob/master/troubleshooting.md
- https://sysadm.mielnet.pl/bacula-and-selinux-denying-access/


### Borg

Установка (на сервере и клиенте):  

```console
[vagrant@bacula-server ~]$ sudo yum install -y epel-release
[vagrant@bacula-server ~]$ sudo yum install -y borgbackup 
```

На сервере бэкапов нужно создать пользователя:  

```console
[vagrant@bacula-server ~]$ sudo useradd -m borg
```

Создать ssh ключи на клиентах и добавить их на сервер:  

```console
[vagrant@bacula-client1 ~]$ ssh-keygen 

[borg@bacula-server ~]$ echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLFxVgxye8Aox6L/LFKKQXZjoM8qy7ynTdtpzKldahRNSlXHwRWh3XKNo725rWV/YbcNy5kwZbdQw0TPBgIDyjigu00hdqzZV5J8Jm9WPKQ1aAbeJu8Ds0ubxuFfnmB1slxAjIX18fX7Zb3wr7/Ys4G+eBte0dvSs4WgV4VhSbav/L3vUSa4xxgxAv+fkv6IMbnzoe/fSAp1RjvsQcswFdkpvztuAIW/EjeKYabpX05JjCAQBx/aSqaEAbH+BLquiFDhSLetfwNFdjy/4LzxEPEb0DaylHcTTqiwyszPU4NzLGPQ3OuGFDkJ16myb+FJj3TPzL3LToKLVvdrLKqKEh vagrant@bacula-client1' >> /home/borg/.ssh/authorized_keys

[borg@bacula-server ~]$ chmod 600 .ssh/authorized_keys
```

Инициализация репозитория borg со стороны клиента:  

```console
[vagrant@bacula-client1 ~]$ borg init -e none borg@192.168.111.10:MyBorgRepo
```

Запускаем бэкап:  

```console
[vagrant@bacula-client1 ~]$ borg create --stats --list borg@192.168.111.10:MyBorgRepo::"FirstBackup-{now:%Y-%m-%d_%H:%M:%S}" /etc            
...
------------------------------------------------------------------------------
Archive name: FirstBackup-2019-09-24_09:21:17
Archive fingerprint: 9f92fc408a78cbecf259b2ad61ab943fb5e5c5b4d5000c90a443a242d6c24b0b
Time (start): Tue, 2019-09-24 09:21:17
Time (end):   Tue, 2019-09-24 09:21:18
Duration: 0.84 seconds
Number of files: 423
Utilization of max. archive size: 0%
------------------------------------------------------------------------------
                       Original size      Compressed size    Deduplicated size
This archive:               17.23 MB              5.78 MB              5.77 MB
All archives:               17.23 MB              5.78 MB              5.77 MB

                       Unique chunks         Total chunks
Chunk index:                     415                  422
------------------------------------------------------------------------------

```

Посмотреть содержимое бэкапа:  

```console
[borg@bacula-server ~]$ borg list MyBorgRepo/
Warning: Attempting to access a previously unknown unencrypted repository!
Do you want to continue? [yN] y
FirstBackup-2019-09-24_09:21:17      Tue, 2019-09-24 09:21:17 [9f92fc408a78cbecf259b2ad61ab943fb5e5c5b4d5000c90a443a242d6c24b0b]
```

Ожидаемо получаем предупреждение.  
Смотрим список всех файлов:  

```console
[borg@bacula-server ~]$ borg list MyBorgRepo::FirstBackup-2019-09-24_09:21:17
drwxr-xr-x root   root          0 Tue, 2019-09-24 09:19:36 etc
-rw-r--r-- root   root        346 Sat, 2019-06-01 17:18:12 etc/fstab
lrwxrwxrwx root   root         17 Sat, 2019-06-01 17:13:31 etc/mtab -> /proc/self/mounts
-rw-r--r-- root   root       2388 Sat, 2019-06-01 17:17:18 etc/libuser.conf
-rw-r--r-- root   root       2043 Sat, 2019-06-01 17:17:19 etc/login.defs
-rw-r--r-- root   root         37 Sat, 2019-06-01 17:17:19 etc/vconsole.conf
lrwxrwxrwx root   root         25 Sat, 2019-06-01 17:17:19 etc/localtime -> ../usr/share/zoneinfo/UTC
-rw-r--r-- root   root         19 Sat, 2019-06-01 17:17:19 etc/locale.conf
-rw-r--r-- root   root        198 Tue, 2019-09-24 09:01:43 etc/hosts
...
```

Извлечение файла из бэкапа:  

```console
[borg@bacula-server ~]$ borg extract MyBorgRepo::FirstBackup-2019-09-24_09:21:17 etc/centos-release
[borg@bacula-server ~]$ 
[borg@bacula-server ~]$ cat etc/centos-release 
CentOS Linux release 7.7.1908 (Core)
```

