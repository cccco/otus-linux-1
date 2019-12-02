# MySQL innodb cluster

Задание:  

развернуть InnoDB кластер в docker 

---

### Запуск

Реализовано в виде docker-compose 

Для запуска: 

```console
docker-compose up
```

### Проверкa

В случае успешного запуска появится информация вида:

```
mysql-shell_1     | Adding instances to the cluster...
mysql-shell_1     | Instances successfully added to the cluster.
mysql-shell_1     | InnoDB cluster deployed successfully.
innodb-cluster_mysql-shell_1 exited with code 0
```

Подключаемся и проверяем состояние кластера:


```console

mysqlsh -u root -pPassw0rd! -P6446 -h 127.0.0.1

MySQL  127.0.0.1:6446 ssl  JS > var cluster = dba.getCluster(); cluster.status()
{
    "clusterName": "otusCluster", 
    "defaultReplicaSet": {
        "name": "default", 
        "primary": "mysql-server-1:3306", 
        "ssl": "REQUIRED", 
        "status": "OK", 
        "statusText": "Cluster is ONLINE and can tolerate up to ONE failure.", 
```

