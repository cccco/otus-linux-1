# LDAP

Задание:  
1. Установить FreeIPA
2. Написать playbook для конфигурации клиента
3. * Настроить авторизацию по ssh-ключам

---

### Реализовано с использованием официальных ansible ролей сервера и клиента

**Прим.**    
Если выделить под VM сервер freeIPA всего 1ГБ оперативной памяти, то плейбук отрабатывает через раз. Если выделить 2ГБ, то ansible работает стабильно.     

Для запуска стенда:  

```console
vagrant up
```

Проверить результаты: 

![network](https://github.com/sinist3rr/otus-linux/blob/master/HW16/images/ipa1.png)

Пробуем добавить нового пользователя:   

```console
[root@ipa ~]# kinit admin
Password for admin@OTUS.LAN: ADMPassword123 

[root@ipa ~]# ipa user-add --first="John" --last="Smith" --cn="John Smith" --password smith --shell="/bin/bash"
Password: 
Enter Password again to verify: 
------------------
Added user "smith"
------------------
  User login: smith
  First name: John
  Last name: Smith
  Full name: John Smith
  Display name: John Smith
  Initials: JS
  Home directory: /home/smith
  GECOS: John Smith
  Login shell: /bin/bash
  Principal name: smith@OTUS.LAN
  Principal alias: smith@OTUS.LAN
  User password expiration: 20191022152909Z
  Email address: smith@otus.lan
  UID: 1287600001
  GID: 1287600001
  Password: True
  Member of groups: ipausers
  Kerberos keys available: True

```
И пробуем на клиенте:  

```console
[root@client ~]# su - smith
Creating home directory for smith.
[smith@client ~]$ 

```

### Добавление ssh ключей

```console
[root@ipa ~]# ipa user-mod smith --sshpubkey="ssh-rsa 12345abcde= ipaclient.otus.lan"
---------------------
Modified user "smith"
---------------------
  User login: smith
  First name: John
  Last name: Smith
  Home directory: /home/smith
  Login shell: /bin/bash
  Principal name: smith@OTUS.LAN
  Principal alias: smith@OTUS.LAN
  Email address: smith@otus.lan
  UID: 1287600001
  GID: 1287600001
  SSH public key: ssh-rsa
                  12345abcde= ipaclient.otus.lan
  SSH public key fingerprint: SHA256:mDA2fFDnCDp9+YCiYcA2svdNECPFCKz+2z8aD1kVzS6 (ssh-rsa)
  Account disabled: False
  Password: True
  Member of groups: ipausers
  Kerberos keys available: True

```

Пробуем подключится с хост машины:

```console
┌─[sinister@desk]─[~/otus-linux/HW16]
└──╼ $ssh -i id_rsa.pub smith@192.168.56.11
Last login: Tue Oct 22 15:40:41 2019 from 192.168.56.1
[smith@client ~]$ 

```
Видим, что подключение по ssh ключу отработало.  

