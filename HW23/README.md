# MAIL

Задание:  

1. Установить postfix+dovecot для приёма почты на виртуальный домен 
2. Отправить почту телнетом с хоста на виртуалку 
3. Принять почту на хост почтовым клиентом 

Результат  
1. Полученное письмо со всеми заголовками   
2. Конфиги postfix и dovecot   


---

### Конфиги

Реализовано без использования СУБД, виртуальные домены и пользователи хранятся в файлах.  

Конфиг postfix -  [postfix](postfix/main.cf)
Конфиг dovecot -  [dovecot](dovecot/dovecot.conf)


### Отправка почты

Проверяем работу на хост машине:  


```console
┌─[sinister@desk]─[~]
└──╼ $ncat 192.168.56.10 25

```

![console](https://github.com/sinist3rr/otus-linux/blob/master/HW23/images/mail1.png)

В почтовом клиенте: 
![thunder](https://github.com/sinist3rr/otus-linux/blob/master/HW23/images/mail2.png)

Сам файл отправленного письма - [mail](email)

