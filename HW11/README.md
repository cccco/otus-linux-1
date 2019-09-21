# Мониторинг

Задание:  
Настроить дашборд с 4-мя графиками  
1) память  
2) процессор  
3) диск  
4) сеть  

настроить на одной из систем   
- zabbix (использовать screen)  
- prometheus - grafana  
---

### Выбран вариант Prometheus/Grafana    

Были использованы следующие официальные роли взятые с ansible galaxy: 

```console
$ansible-galaxy install --roles-path ./provision/roles/ cloudalchemy.prometheus
$ansible-galaxy install --roles-path ./provision/roles/ cloudalchemy.node-exporter
$ansible-galaxy install --roles-path ./provision/roles/ cloudalchemy.grafana
```

&#x1F534; **Важно!**   
&#x1F534; Перед запуском требуется установить:  

```console
pip install jmespath
```

Затем можно запускать:

```console
vagrant up
```
После развертывания и провижининга, появляется возможность подключиться как к prometheus (http://localhost:9090), так и к grafana (http://localhost:3000)  

Логин:пароль для доступа к grafana - admin:admin.  

После добавления и конфигурирования дашборда получается следующий вид: 

![Grafana1](https://github.com/sinist3rr/otus-linux/blob/master/HW11/images/grafana1.png)
![Grafana2](https://github.com/sinist3rr/otus-linux/blob/master/HW11/images/grafana2.png)

Так же можно установить NetData:  

```console
bash <(curl -Ss https://my-netdata.io/kickstart.sh)
```

![NetData](https://github.com/sinist3rr/otus-linux/blob/master/HW11/images/netdata.png)

