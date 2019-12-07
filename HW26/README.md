# PostgreSQL

Задание:  

- Настроить hot_standby репликацию с использованием слотов
- Настроить правильное резервное копирование

---

### Запуск

Реализовано в виде ролeй ansible.   

Для запуска: 

```console
vagrant up
```

### Проверки

Проверяем работу репликации. 
Для этого создаем простую таблицу на мастере: 


```
-- create a sequence that will serve as the PK of the employees table
create sequence employees_seq start with 1 increment by 1 no maxvalue minvalue 1 cache 1;
-- create the employees table
create table employees (
        emp_id numeric primary key default nextval('employees_seq'::regclass),
        first_name text not null,
        last_name text not null,
        birth_year numeric not null,
        birth_month numeric not null,
        birth_dayofmonth numeric not null
);
-- insert some data into the table
insert into employees (first_name, last_name, birth_year, birth_month, birth_dayofmonth) values ('Emily','James',1983,03,20);
insert into employees (first_name, last_name, birth_year, birth_month, birth_dayofmonth) values ('John','Smith',1990,08,12);
```

```console
[root@master ~]# su - postgres
-bash-4.2$ 
-bash-4.2$ psql < /tmp/sample.sql 
CREATE SEQUENCE
CREATE TABLE
INSERT 0 1
INSERT 0 1
-bash-4.2$ 
-bash-4.2$ psql 
psql (11.6)
Type "help" for help.

postgres=# select * from employees;
 emp_id | first_name | last_name | birth_year | birth_month | birth_dayofmonth 
--------+------------+-----------+------------+-------------+------------------
      1 | Emily      | James     |       1983 |           3 |               20
      2 | John       | Smith     |       1990 |           8 |               12
(2 rows)

```

И смотрим что на слейве:   

```console
[root@slave ~]# su - postgres
-bash-4.2$ 
-bash-4.2$ psql 
psql (11.6)
Type "help" for help.

postgres=# select * from employees;
 emp_id | first_name | last_name | birth_year | birth_month | birth_dayofmonth 
--------+------------+-----------+------------+-------------+------------------
      1 | Emily      | James     |       1983 |           3 |               20
      2 | John       | Smith     |       1990 |           8 |               12
(2 rows)

```

Проверяем работу barman:  

```console
[root@backup ~]# barman check master
Server master:
	PostgreSQL: OK
	is_superuser: OK
	PostgreSQL streaming: OK
	wal_level: OK
	replication slot: OK
	directories: OK
	retention policy settings: OK
	backup maximum age: OK (no last_backup_maximum_age provided)
	compression settings: OK
	failed backups: OK (there are 0 failed backups)
	minimum redundancy requirements: OK (have 0 backups, expected at least 0)
	pg_basebackup: OK
	pg_basebackup compatible: OK
	pg_basebackup supports tablespaces mapping: OK
	systemid coherence: OK (no system Id stored on disk)
	pg_receivexlog: OK
	pg_receivexlog compatible: OK
	receive-wal running: OK
	archive_mode: OK
	archive_command: OK
	continuous archiving: OK
	archiver errors: OK
[root@backup ~]# 
[root@backup ~]# barman status master
Server master:
	Description: PostgreSQL Backup
	Active: True
	Disabled: False
	PostgreSQL version: 11.6
	Cluster state: in production
	pgespresso extension: Not available
	Current data size: 22.8 MiB
	PostgreSQL Data directory: /var/lib/pgsql/11/data
	Current WAL segment: 000000010000000000000003
	PostgreSQL 'archive_command' setting: barman-wal-archive backup master %p
	Last archived WAL: 000000010000000000000002.00000060.backup, at Sat Dec  7 11:35:04 2019
	Failures of WAL archiver: 6 (000000010000000000000001 at Sat Dec  7 11:34:02 2019)
	Server WAL archiving rate: 54.81/hour
	Passive node: False
	Retention policies: not enforced
	No. of available backups: 0
	First available backup: None
	Last available backup: None
	Minimum redundancy requirements: satisfied (0/0)
[root@backup ~]# 
[root@backup ~]# barman replication-status master
Status of streaming clients for server 'master':
  Current LSN on master: 0/3000060
  Number of streaming clients: 2

  1. Async standby
     Application name: walreceiver
     Sync stage      : 5/5 Hot standby (max)
     Communication   : TCP/IP
     IP Address      : 192.168.56.20 / Port: 56828 / Host: -
     User name       : streaming_user
     Current state   : streaming (async)
     Replication slot: pg_slot_1
     WAL sender PID  : 7946
     Started at      : 2019-12-07 11:33:46.284299+00:00
     Sent LSN   : 0/3000060 (diff: 0 B)
     Write LSN  : 0/3000060 (diff: 0 B)
     Flush LSN  : 0/3000060 (diff: 0 B)
     Replay LSN : 0/3000060 (diff: 0 B)

  2. Async WAL streamer
     Application name: barman_receive_wal
     Sync stage      : 3/3 Remote write
     Communication   : TCP/IP
     IP Address      : 192.168.56.30 / Port: 50018 / Host: -
     User name       : barman_streaming_user
     Current state   : streaming (async)
     Replication slot: barman
     WAL sender PID  : 7978
     Started at      : 2019-12-07 11:35:04.644459+00:00
     Sent LSN   : 0/3000060 (diff: 0 B)
     Write LSN  : 0/3000060 (diff: 0 B)
     Flush LSN  : 0/3000000 (diff: -96 B)
[root@backup ~]# 
[root@backup ~]# barman switch-wal --archive master
The WAL file 000000010000000000000003 has been closed on server 'master'
Waiting for the WAL file 000000010000000000000003 from server 'master' (max: 30 seconds)
Processing xlog segments from file archival for master
	000000010000000000000003
[root@backup ~]# 
[root@backup ~]# barman backup master
Starting backup using postgres method for server master in /var/lib/barman/master/base/20191207T113910
Backup start at LSN: 0/4000000 (000000010000000000000003, 00000000)
Starting backup copy via pg_basebackup for 20191207T113910
Copy done (time: 2 seconds)
Finalising the backup.
This is the first backup for server master
WAL segments preceding the current backup have been found:
	000000010000000000000001 from server master has been removed
	000000010000000000000002 from server master has been removed
	000000010000000000000002.00000060.backup from server master has been removed
	000000010000000000000003 from server master has been removed
Backup size: 22.7 MiB
Backup end at LSN: 0/5000060 (000000010000000000000005, 00000060)
Backup completed (start time: 2019-12-07 11:39:10.170807, elapsed time: 2 seconds)
Processing xlog segments from streaming for master
	000000010000000000000003
	000000010000000000000004
Processing xlog segments from file archival for master
	000000010000000000000004
	000000010000000000000004.00000028.backup
[root@backup ~]# 
[root@backup ~]# barman list-backup master
master 20191207T113910 - Sat Dec  7 11:39:12 2019 - Size: 22.7 MiB - WAL Size: 0 B
[root@backup ~]# 
[root@backup ~]# barman check master
Server master:
	PostgreSQL: OK
	is_superuser: OK
	PostgreSQL streaming: OK
	wal_level: OK
	replication slot: OK
	directories: OK
	retention policy settings: OK
	backup maximum age: OK (no last_backup_maximum_age provided)
	compression settings: OK
	failed backups: OK (there are 0 failed backups)
	minimum redundancy requirements: OK (have 1 backups, expected at least 0)
	pg_basebackup: OK
	pg_basebackup compatible: OK
	pg_basebackup supports tablespaces mapping: OK
	systemid coherence: OK
	pg_receivexlog: OK
	pg_receivexlog compatible: OK
	receive-wal running: OK
	archive_mode: OK
	archive_command: OK
	continuous archiving: OK
	archiver errors: OK

```

