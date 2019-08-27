# Работа с загрузчиком Linux 

Задания: 
1. Попасть в систему без пароля несколькими способами 
2. Установить систему с LVM, после чего переименовать VG 
3. Добавить модуль в initrd 

4. (*) Сконфигурировать систему без отдельного раздела с /boot, а только с LVM  
---

### 1. Сброс пароля пользователя root 

**Способ №1**

Cпособ основан на изменении процесса с которого стартует ядро.

Загружаемся в grub, нажимаем "e" и переходим в режим редактирования.

![grub](https://github.com/sinist3rr/otus-linux/blob/master/HW07/images/grub.png)

Находим строку, которая начинается на linux16 и дописываем вместо "ro" строку "rw init=/sysroot/bin/sh" 

![init](https://github.com/sinist3rr/otus-linux/blob/master/HW07/images/init.png)

Жмем Ctrl-X и загружаемся в минималистичный шелл.

![init_sh](https://github.com/sinist3rr/otus-linux/blob/master/HW07/images/init_sh.png)

```console
:/# chroot /sysroot/
:/# passwd root
Changing password for user root.
New password:
Retype new password:
passwd: all authentication tokens updated successfully.
:/# touch /.autorelabel
```

Для перезагрузки нужно выполнить команду 
```console
:/# reboot -f 
```
*Просто reboot без ключей не отработает.* 


**Способ №2**

Этот способ использует rd.break для прерывания процесса загрузки до того как контроль будет передан от initramfs к systemd. 

Останавливаемся в загрузчике grub, переходим в редактирование. 
Находим строку которая начинается на "linux16" и дописываем в конец "rd.break" 

![rd](https://github.com/sinist3rr/otus-linux/blob/master/HW07/images/rd.png)

Нажимаем Ctrl-X и попадаем в шелл 

![rd_shell](https://github.com/sinist3rr/otus-linux/blob/master/HW07/images/rd_shell.png)

```console 
switch_root:/# mount | grep sysroot
/dev/mapper/centos7-root on /sysroot type xfs (ro,relatime,attr2,inode64,noquota)
````

Видим, что корень примонтирован в режиме только для чтения.

```console 
switch_root:/# mount -o remount,rw /sysroot
```

Перемонтировали в режиме чтения/записи. 

```console
switch_root:/# chroot /sysroot/
sh-4.2# passwd
Changing password for user root.
New password:
Retype new password:
passwd: all authentication tokens updated successfully.
sh-4.2# touch /.autorelabel
```

Переазгружаемся чтобы зайти с измененным паролем:
```console
sh-4.2# exit
switch_root:/# reboot
```

