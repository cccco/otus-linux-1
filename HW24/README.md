# MySQL

Задание:  


развернуть базу из дампа и настроить репликацию  
В материалах приложены ссылки на вагрант для репликации  
и дамп базы bet.dmp  
базу развернуть на мастере  
и настроить чтобы реплицировались таблицы  
| bookmaker |
| competition |
| market |
| odds |
| outcome

* Настроить GTID репликацию  

---

### Запуск

Реализовано в виде ролeй ansible.   

Для запуска: 

```console
vagrant up
```

### Проверки

Проверяем работу на мастере:  


```console
mysql> SELECT @@server_id;                                         
+-------------+
| @@server_id |
+-------------+
|           1 |
+-------------+
1 row in set (0.00 sec)

mysql> 
mysql> 
mysql> show tables;       
+------------------+
| Tables_in_bet    |
+------------------+
| bookmaker        |
| competition      |
| events_on_demand |
| market           |
| odds             |
| outcome          |
| v_same_event     |
+------------------+
7 rows in set (0.00 sec)

mysql> INSERT INTO bookmaker (id,bookmaker_name) VALUES(8,'8xbet');
Query OK, 1 row affected (0.00 sec)
```

```console
[root@master ~]# mysqlbinlog /var/lib/mysql/mysql-bin.000001 


BEGIN
/*!*/;
# at 332
#191127 14:58:17 server id 1  end_log_pos 459 CRC32 0x3f3b3fb1 	Query	thread_id=4	exec_time=0	error_code=0
use `bet`/*!*/;
SET TIMESTAMP=1574866697/*!*/;
INSERT INTO bookmaker (id,bookmaker_name) VALUES(8,'8xbet')
/*!*/;
# at 459
#191127 14:58:17 server id 1  end_log_pos 490 CRC32 0xec5a65ca 	Xid = 27
COMMIT/*!*/;
...
```

На слейве:   

```console
mysql> 
mysql> SELECT @@server_id;             
+-------------+
| @@server_id |
+-------------+
|           2 |
+-------------+
1 row in set (0.00 sec)

mysql> show tables;
+---------------+
| Tables_in_bet |
+---------------+
| bookmaker     |
| competition   |
| market        |
| odds          |
| outcome       |
+---------------+
5 rows in set (0.00 sec)

mysql> SELECT * FROM bookmaker;
+----+----------------+
| id | bookmaker_name |
+----+----------------+
|  8 | 8xbet          |
|  4 | betway         |
|  5 | bwin           |
|  6 | ladbrokes      |
|  3 | unibet         |
+----+----------------+
5 rows in set (0.00 sec)

```


```console
[root@slave ~]# mysqlbinlog /var/lib/mysql/mysql-bin.000002

BEGIN
/*!*/;
# at 332
#191127 14:58:17 server id 1  end_log_pos 459 CRC32 0x3f3b3fb1 	Query	thread_id=4	exec_time=0	error_code=0
use `bet`/*!*/;
SET TIMESTAMP=1574866697/*!*/;
INSERT INTO bookmaker (id,bookmaker_name) VALUES(8,'8xbet')
/*!*/;
# at 459
#191127 14:58:17 server id 1  end_log_pos 490 CRC32 0x43044f54 	Xid = 3
COMMIT/*!*/;
...
```


