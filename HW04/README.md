# Написание скриптов на bash

Задание:
написать скрипт для крона 
который раз в час присылает на заданную почту 
- X IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта 
- Y запрашиваемых адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта 
- все ошибки c момента последнего запуска 
- список всех кодов возврата с указанием их кол-ва с момента последнего запуска 
в письме должно быть прописан обрабатываемый временной диапазон 
должна быть реализована защита от мультизапуска 

---

### Ниже демонстрируется работа скрипта при появлении новых записей в лог файле: 

```console

sudo bash nginx_parser.sh
```


Получаем следующее письмо:

```
From root Wed Aug 14 17:02:32 2019
Date: Wed, 14 Aug 2019 17:02:32 +0300
To: root@localhost
Subject: nginx log stats
User-Agent: mail v14.9.14

top 10 ip-addresses:
     179 194.31.xx.xx
    177 194.28.xx.xx
    132 127.0.0.1
     71 178.209.xx.xx
     55 213.110.xx.xx
     49 91.217.xx.xx
     41 91.225.xx.xx
     30 46.162.xx.xx
     29 93.72.xx.xx
     24 82.117.xx.xx

 top 10 requests:
     258 /
     70 /whm-server-status
     41 /login
     35 /category
     35 /cart/add
     32 /cart/show
     29 /makeToken
     28 /cart/update
     27 /validateToken
     17 /cart/done

 HTTP errors:
400 -       1 /html/SetSmarcardSettings.php
404 -       1 /.well-known/security.txt
405 -       5 /product/makeToken
422 -       3 /makeToken
499 -      70 /whm-server-status
500 -       3 /cart/show
502 -       1 //%63%67%69%2D%62%69%6E/%70%68%70?%2D%64+%61%6C%6C%6F%77%5F%75%72%6C%5F%69%6E%63%6C%75%64%65%3D%6F%6E+%2D%64+%73%61%66%65%5F%6D%6F%64%65%3...

 All HTTP codes:
200 - 778
201 - 26
302 - 103
400 - 2
404 - 2
405 - 5
422 - 3
499 - 75
500 - 4
502 - 1
```

При этом в файле содержащем номер последней строки: 
```console
cat /var/local/lnfile
1000
```

После увеличения файла, видим, что значения изменились:

```
From root Wed Aug 14 17:03:36 2019
Date: Wed, 14 Aug 2019 17:03:36 +0300
To: root@localhost
Subject: nginx log stats
User-Agent: mail v14.9.14

top 10 ip-addresses:
     170 91.217.xx.xx
     95 46.174.xx.xx
     65 217.147.xx.xx
     60 193.107.xx.xx
     53 194.44.xx.xx
     52 62.80.xx.xx
     49 193.110.xx.xx
     41 80.78.xx.xx
     39 176.36.xx.xx
     27 95.164.xx.xx

 top 10 requests:
      82 /login  
     59 /category
     47 /makeToken
     37 /validateToken
     37 /cart/add
     33 /
     24 /cart/show
     15 /filter
     14 /cart/list
     10 /cart/update

 HTTP errors:
422 -       7 /makeToken
499 -       8 /whm-server-status
500 -       4 /cart/show

 All HTTP codes:
200 - 812
201 - 36
302 - 124
422 - 7
499 - 17
500 - 4
```

При этом количество строк увеличилось вдвое: 

```console
cat /var/local/lnfile
2000
```

