# Работа с RPM пакетами и репозитариями Linux

Задание: 
Размещаем свой RPM в своем репозитории  
Цель: Часто в задачи администратора входит не только установка пакетов, но и сборка и поддержка собственного репозитория.
1) создать свой RPM (можно взять свое приложение, либо собрать к примеру апач с определенными опциями) 
2) создать свой репо и разместить там свой RPM 
---

### Реализовано в виде двух боксов Vagrant 

После деплоя и провиженинга обоих боксов Vagrant, переходим на клиента и смотрим все подключенные репозитории:  

```console

[vagrant@client ~]$ yum repolist
Loaded plugins: fastestmirror
Determining fastest mirrors
 * base: centos.colocall.net
 * extras: centos.colocall.net
 * updates: centos.colocall.net
base                                                                             | 3.6 kB  00:00:00     
extras                                                                           | 3.4 kB  00:00:00     
repo_server-repo                                                                 | 2.9 kB  00:00:00     
updates                                                                          | 3.4 kB  00:00:00     
repo_server-repo/primary_db                                                      | 2.6 kB  00:00:00     
repo id                                     repo name                                             status
base/7/x86_64                               CentOS-7 - Base                                       10,019
extras/7/x86_64                             CentOS-7 - Extras                                        435
repo_server-repo                            My RPM NGINX Package Repo                                  1
updates/7/x86_64                            CentOS-7 - Updates                                     2,500
repolist: 12,955

```

Видно, что на клиенте в списке репозиториев есть наш кастомный репозиторий "repo_server-repo". 

```console

[vagrant@client ~]$ yum --disablerepo="*" --enablerepo="repo_server-repo" list available
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
Available Packages
nginx.x86_64                             1:1.16.1-1.el7.ngx                             repo_server-repo

```

В этом репозитории лежит один собранный пакет, пробуем его установить: 

```console

[vagrant@client ~]$ sudo yum install nginx
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: centos.colocall.net
 * extras: centos.colocall.net
 * updates: centos.colocall.net
base                                                                             | 3.6 kB  00:00:00     
extras                                                                           | 3.4 kB  00:00:00     
repo_server-repo                                                                 | 2.9 kB  00:00:00     
updates                                                                          | 3.4 kB  00:00:00     
repo_server-repo/primary_db                                                      | 2.6 kB  00:00:00     
Resolving Dependencies
--> Running transaction check
---> Package nginx.x86_64 1:1.16.1-1.el7.ngx will be installed
--> Finished Dependency Resolution

Dependencies Resolved

========================================================================================================
 Package           Arch               Version                        Repository                    Size
========================================================================================================
Installing:
 nginx             x86_64             1:1.16.1-1.el7.ngx             repo_server-repo             3.5 M

Transaction Summary
========================================================================================================
Install  1 Package

```

Проверяем версию openssl: 

```console

[vagrant@client ~]$ nginx -V
nginx version: nginx/1.16.1
built by gcc 4.8.5 20150623 (Red Hat 4.8.5-36) (GCC) 
built with OpenSSL 1.1.1c  28 May 2019

```
Пакет был успешно собран и установлен с самым свежим релизом openssl. 




