# Logging

Задание:  
Настраиваем центральный сервер для сбора логов
в вагранте поднимаем 2 машины web и log
на web поднимаем nginx
на log настраиваем центральный лог сервер на любой системе на выбор:
- journald
- rsyslog
- elk

Настраиваем аудит следящий за изменением конфигов nginx
Все критичные логи с web должны собираться и локально и удаленно
Все логи с nginx должны уходить на удаленный сервер (локально только критичные)
Логи аудита должны также уходить на удаленную систему

* Развернуть еще машину ELK

---

### Был выбран ryslog 

Для запуска:

```console
vagrant up
```

Результаты после двух часов работы:  

```
lits files jobid=19
```

![bacula2](https://github.com/sinist3rr/otus-linux/blob/master/HW12/images/bacula2.png)

[list files jobid=19](https://github.com/sinist3rr/otus-linux/blob/master/HW12/jobid19.log) (Full)


Полезные материалы:  
- https://github.com/tyler-hitzeman/bacula/blob/master/troubleshooting.md
- https://sysadm.mielnet.pl/bacula-and-selinux-denying-access/


### Работа с ELK


