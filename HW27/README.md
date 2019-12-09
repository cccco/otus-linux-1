# PostgreSQL cluster

Задание:  

Развернуть кластер PostgreSQL из трех нод. 
Создать тестовую базу - проверить статус репликации 
Сделать switchover/failover 
Поменять конфигурацию PostgreSQL + с параметром требующим перезагрузки


---

### Запуск

Реализовано в виде ролей ansible.  

Для запуска: 

```console
vagrant up
```

### Проверки


Для более удобной работы ansible сразу добавляет следующие переменные окружения для рута на каждую ноду:  

```
export PGHOST=192.168.56.21
export CONSUL_HTTP_ADDR=192.168.56.10:8500
export PATRONI_CONSUL_HOST=192.168.56.10:8500
export PGUSER=postgres
export PGPASSWORD='gfhjkm'
export PGPORT=5432
export PGDATABASE=postgres
```

Создать тестовую базу и проверить работу репликации: 

```console
[root@pg1 ~]# psql -h 192.168.56.21
psql (9.2.24, server 11.6)
Type "help" for help.

postgres=# create database otus;
CREATE DATABASE
postgres=# \l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 otus      | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
(4 rows)

postgres=# \q
[root@pg1 ~]# 
[root@pg1 ~]# psql -h 192.168.56.22
psql (9.2.24, server 11.6)
Type "help" for help.

postgres=# \l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 otus      | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
(4 rows)

postgres-# \q
[root@pg1 ~]# psql -h 192.168.56.23
psql (9.2.24, server 11.6)
Type "help" for help.

postgres=# \l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 otus      | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
(4 rows)

```

Проверяем автоматический failover:  

```console
[root@pg1 ~]# patronictl list otus
+---------+--------+---------------+--------+---------+----+-----------+
| Cluster | Member |      Host     |  Role  |  State  | TL | Lag in MB |
+---------+--------+---------------+--------+---------+----+-----------+
|   otus  |  pg1   | 192.168.56.21 | Leader | running |  1 |           |
|   otus  |  pg2   | 192.168.56.22 |        | running |  1 |       0.0 |
|   otus  |  pg3   | 192.168.56.23 |        | running |  1 |       0.0 |
+---------+--------+---------------+--------+---------+----+-----------+
[root@pg1 ~]# systemctl stop patroni
[root@pg1 ~]# 
[root@pg1 ~]# patronictl list otus
+---------+--------+---------------+--------+---------+----+-----------+
| Cluster | Member |      Host     |  Role  |  State  | TL | Lag in MB |
+---------+--------+---------------+--------+---------+----+-----------+
|   otus  |  pg1   | 192.168.56.21 |        | stopped |    |   unknown |
|   otus  |  pg2   | 192.168.56.22 |        | running |  2 |       0.0 |
|   otus  |  pg3   | 192.168.56.23 | Leader | running |  2 |           |
+---------+--------+---------------+--------+---------+----+-----------+
[root@pg1 ~]# 

```

Проверяем swithover:  


```console
[root@pg1 ~]# systemctl start patroni
[root@pg1 ~]# patronictl list otus
+---------+--------+---------------+--------+---------+----+-----------+
| Cluster | Member |      Host     |  Role  |  State  | TL | Lag in MB |
+---------+--------+---------------+--------+---------+----+-----------+
|   otus  |  pg1   | 192.168.56.21 |        | running |  2 |       0.0 |
|   otus  |  pg2   | 192.168.56.22 |        | running |  2 |       0.0 |
|   otus  |  pg3   | 192.168.56.23 | Leader | running |  2 |           |
+---------+--------+---------------+--------+---------+----+-----------+
[root@pg1 ~]# patronictl switchover --master pg3 --candidate pg1 otus
When should the switchover take place (e.g. 2019-12-09T17:30 )  [now]: 
Current cluster topology
+---------+--------+---------------+--------+---------+----+-----------+
| Cluster | Member |      Host     |  Role  |  State  | TL | Lag in MB |
+---------+--------+---------------+--------+---------+----+-----------+
|   otus  |  pg1   | 192.168.56.21 |        | running |  2 |       0.0 |
|   otus  |  pg2   | 192.168.56.22 |        | running |  2 |       0.0 |
|   otus  |  pg3   | 192.168.56.23 | Leader | running |  2 |           |
+---------+--------+---------------+--------+---------+----+-----------+
Are you sure you want to switchover cluster otus, demoting current master pg3? [y/N]: y
2019-12-09 16:30:14.98849 Successfully switched over to "pg1"
+---------+--------+---------------+--------+---------+----+-----------+
| Cluster | Member |      Host     |  Role  |  State  | TL | Lag in MB |
+---------+--------+---------------+--------+---------+----+-----------+
|   otus  |  pg1   | 192.168.56.21 | Leader | running |  2 |           |
|   otus  |  pg2   | 192.168.56.22 |        | running |  2 |       0.0 |
|   otus  |  pg3   | 192.168.56.23 |        | stopped |    |   unknown |
+---------+--------+---------------+--------+---------+----+-----------+
[root@pg1 ~]# 
[root@pg1 ~]# patronictl list otus
+---------+--------+---------------+--------+---------+----+-----------+
| Cluster | Member |      Host     |  Role  |  State  | TL | Lag in MB |
+---------+--------+---------------+--------+---------+----+-----------+
|   otus  |  pg1   | 192.168.56.21 | Leader | running |  3 |           |
|   otus  |  pg2   | 192.168.56.22 |        | running |  3 |       0.0 |
|   otus  |  pg3   | 192.168.56.23 |        | running |  3 |       0.0 |
+---------+--------+---------------+--------+---------+----+-----------+
[root@pg1 ~]# 

```

Меняем параметр (max_connections), требующий перезапуска кластера: 

```console
[root@pg1 ~]# patronictl edit-config otus
--- 
+++ 
@@ -7,7 +7,7 @@
       archive-push -B /var/backup --instance dbdc2 --wal-file-path=%p --wal-file-name=%f
       --remote-host=10.23.1.185
     archive_mode: 'on'
-    max_connections: 100
+    max_connections: 50
     max_parallel_workers: 8
     max_wal_senders: 5
     max_wal_size: 2GB

Apply these changes? [y/N]: y
Configuration changed

[root@pg1 ~]# 
[root@pg1 ~]# patronictl list otus
+---------+--------+---------------+--------+---------+----+-----------+-----------------+
| Cluster | Member |      Host     |  Role  |  State  | TL | Lag in MB | Pending restart |
+---------+--------+---------------+--------+---------+----+-----------+-----------------+
|   otus  |  pg1   | 192.168.56.21 | Leader | running |  3 |           |        *        |
|   otus  |  pg2   | 192.168.56.22 |        | running |  3 |       0.0 |        *        |
|   otus  |  pg3   | 192.168.56.23 |        | running |  3 |       0.0 |        *        |
+---------+--------+---------------+--------+---------+----+-----------+-----------------+
[root@pg1 ~]# 
[root@pg1 ~]# patronictl restart otus
+---------+--------+---------------+--------+---------+----+-----------+-----------------+
| Cluster | Member |      Host     |  Role  |  State  | TL | Lag in MB | Pending restart |
+---------+--------+---------------+--------+---------+----+-----------+-----------------+
|   otus  |  pg1   | 192.168.56.21 | Leader | running |  3 |           |        *        |
|   otus  |  pg2   | 192.168.56.22 |        | running |  3 |       0.0 |        *        |
|   otus  |  pg3   | 192.168.56.23 |        | running |  3 |       0.0 |        *        |
+---------+--------+---------------+--------+---------+----+-----------+-----------------+
When should the restart take place (e.g. 2019-12-09T17:37)  [now]: 
Are you sure you want to restart members pg2, pg3, pg1? [y/N]: y
Restart if the PostgreSQL version is less than provided (e.g. 9.5.2)  []: 
Success: restart on member pg2
Success: restart on member pg3
Success: restart on member pg1
[root@pg1 ~]# 

```

