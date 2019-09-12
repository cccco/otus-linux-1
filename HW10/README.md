# PAM

Задание:  
1. Запретить всем пользователям, кроме группы admin логин в выходные(суббота и воскресенье), без учета праздников
2. Дать конкретному пользователю права рута 
---

### 1. Запретить всем пользователям кроме группы admin логин в выходные. Реализовано в виде ansible роли 

Перепробовал все варианты и с помощью **pam_listfile** и с помощью  **pam_succeed_if**, но остановился в итоге на **pam_script**, как самый надежный вариант.

Запускается как обычно:

```console
vagrant up
```
После развертывания и провижининга, появляется возможность подключаться по ssh используя учетные данные user1:pass1 и user2:pass2.

Если установить дату на выходной день, то user1 сразу же теряет возможность зайти по ssh: 

```console

Sep 07 09:00:10 pam sshd[11275]: Failed password for user1 from 192.168.56.1 port 50736 ssh2
Sep 07 09:00:10 pam sshd[11275]: fatal: Access denied for user user1 by PAM account configuration [preauth]

```
При этом user2, который находится в группе admin, подключается в выходной день без проблем: 

```console

Sep 07 09:01:00 pam sshd[11286]: Accepted password for user2 from 192.168.56.1 port 50742 ssh2
Sep 07 09:01:00 pam systemd[1]: Created slice User Slice of user2.
Sep 07 09:01:00 pam systemd[1]: Started Session 21 of user user2.
Sep 07 09:01:00 pam systemd-logind[1260]: New session 21 of user user2.
Sep 07 09:01:00 pam sshd[11286]: pam_unix(sshd:session): session opened for user user2 by (uid=0)

```

### 2. Дать конкретному пользователю права рута

С помощью /etc/pam.d/su можно выдавать права на выполнение su, например: 

```console
account         [success=1 default=ignore] \
                                pam_succeed_if.so user = vagrant:user2 use_uid quiet
account         required        pam_succeed_if.so user notin root:vagrant:user2
```
Но задачу ДЗ это не выполняет, поэтому самый оптимальный вариант попрежнему visudo: 

```console

user2	ALL=(ALL) 	ALL

```

При этом пользователь сможет использовать sudo для выполнения любых команд.      
Если требуется sudo без пароля, то:     

```console
user2        ALL=(ALL)       NOPASSWD: ALL
```

---

Полезные материалы:  

https://www.digitalocean.com/community/tutorials/how-to-set-up-multi-factor-authentication-for-ssh-on-centos-7 


https://8192.one/post/ssh_login_notification_withtelegram/ 

https://access.redhat.com/solutions/64860 

