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
From root Thu Aug 15 15:20:04 2019
Date: Thu, 15 Aug 2019 15:20:04 +0300
To: root@localhost
Subject: nginx log stats
User-Agent: mail v14.9.14

Time range:
 15/Aug/2019:09:38:16 - 15/Aug/2019:09:59:33

Top 10 ip-addresses:
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

 Top 10 requests:
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
4000
```

После увеличения файла, видим, что значения и время изменились:

```
From root Thu Aug 15 15:32:36 2019
Date: Thu, 15 Aug 2019 15:32:36 +0300
To: root@localhost
Subject: nginx log stats
User-Agent: mail v14.9.14

Time range:
 15/Aug/2019:09:59:34 - 15/Aug/2019:10:43:54

 Top 10 ip-addresses:
     264 91.196.xx.xx
    167 213.227.xx.xx
    144 176.36.xx.xx
    115 91.217.xx.xx
    115 176.37.xx.xx
    106 195.68.xx.xx
     87 77.47.xx.xx
     87 178.159.xx.xx
     81 37.73.xx.xx
     62 62.216.xx.xx

 Top 10 requests:
     126 /cart/add
     74 /cart/show
     54 /index.php/category
     52 /category
     41 /login
     40 /autocomplete?search=1
     34 /index.php/login
     34 /index.php
     34 /
     30 /autocomplete?search=19-

 HTTP errors:
 422 -       4 /makeToken
499 -       9 /whm-server-status

 All HTTP codes:
 200 - 1755
201 - 25
302 - 187
422 - 4
499 - 29
```

При этом количество строк тоже увеличилось: 

```console
cat /var/local/lnfile
6000
```

