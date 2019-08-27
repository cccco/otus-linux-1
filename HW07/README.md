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

### 2. Установить систему с LVM, после чего переименовать VG

(Использовался Vagrantfile из ДЗ по LVM) 

Изначально имеем: 

```console
[vagrant@lvm ~]$ lsblk 
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   40G  0 disk 
├─sda1                    8:1    0    1M  0 part 
├─sda2                    8:2    0    1G  0 part /boot
└─sda3                    8:3    0   39G  0 part 
  ├─VolGroup00-LogVol00 253:0    0 37.5G  0 lvm  /
  └─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
sdb                       8:16   0   10G  0 disk 
sdc                       8:32   0    2G  0 disk 
sdd                       8:48   0    1G  0 disk 
sde                       8:64   0    1G  0 disk 

[vagrant@lvm ~]$ sudo vgs
  VG         #PV #LV #SN Attr   VSize   VFree
  VolGroup00   1   2   0 wz--n- <38.97g    0 
```

Переименовываем VG: 

```console
[vagrant@lvm ~]$ sudo vgrename -v VolGroup00 newvg
    Wiping cache of LVM-capable devices
    Archiving volume group "VolGroup00" metadata (seqno 3).
    Writing out updated volume group
    Renaming "/dev/VolGroup00" to "/dev/newvg"
    Loading table for VolGroup00-LogVol00 (253:0).
    Suppressed VolGroup00-LogVol00 (253:0) identical table reload.
    Suspending VolGroup00-LogVol00 (253:0) with device flush
    Loading table for VolGroup00-LogVol00 (253:0).
    Suppressed VolGroup00-LogVol00 (253:0) identical table reload.
    Renaming VolGroup00-LogVol00 (253:0) to newvg-LogVol00
    Resuming newvg-LogVol00 (253:0).
    Loading table for VolGroup00-LogVol01 (253:1).
    Suppressed VolGroup00-LogVol01 (253:1) identical table reload.
    Suspending VolGroup00-LogVol01 (253:1) with device flush
    Loading table for VolGroup00-LogVol01 (253:1).
    Suppressed VolGroup00-LogVol01 (253:1) identical table reload.
    Renaming VolGroup00-LogVol01 (253:1) to newvg-LogVol01
    Resuming newvg-LogVol01 (253:1).
    Creating volume group backup "/etc/lvm/backup/newvg" (seqno 4).
  Volume group "VolGroup00" successfully renamed to "newvg"
```

Проверяем: 

```console
[vagrant@lvm ~]$ sudo vgs
  VG    #PV #LV #SN Attr   VSize   VFree
  newvg   1   2   0 wz--n- <38.97g    0 
```

Для того чтобы система могла загрузиться и работать нужно изменить значения VG в двух конфигах: 

```console
[vagrant@lvm ~]$ sudo sed -i "s/VolGroup00/newvg/g" /etc/fstab
[vagrant@lvm ~]$ sudo sed -i "s/VolGroup00/newvg/g" /boot/grub2/grub.cfg
```

После перезагрузки: 

```console
[vagrant@lvm ~]$ lsblk 
NAME               MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                  8:0    0   40G  0 disk 
├─sda1               8:1    0    1M  0 part 
├─sda2               8:2    0    1G  0 part /boot
└─sda3               8:3    0   39G  0 part 
  ├─newvg-LogVol00 253:0    0 37.5G  0 lvm  /
  └─newvg-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
sdb                  8:16   0   10G  0 disk 
sdc                  8:32   0    2G  0 disk 
sdd                  8:48   0    1G  0 disk 
sde                  8:64   0    1G  0 disk 
```

### 3. Добавляем кастомный модуль в initrd


```console
[root@lvm ~]# mkdir /usr/lib/dracut/modules.d/01pinguin

[root@lvm ~]# cat << EOF > /usr/lib/dracut/modules.d/01pinguin/module-setup.sh
#!/bin/bash

check () {
    return 0
}

depends() {
    return 0
}

install() {
    inst_hook cleanup 00 "${moddir}/print-pinguin.sh"
}
EOF

[root@lvm ~]# cat << EOF > /usr/lib/dracut/modules.d/01pinguin/print-pinguin.sh
#!/bin/bash

exec 0<>/dev/console 1<>/dev/console 2<>/dev/console

cat <<'msgend'
_______________________
< I'm dracut module  >
 -----------------------
   \
    \
        .--.
       |o_o |
       |:_/ |
      //   \ \
     (|     | )
    /'\_   _/'\
    \___)=(___/

msgend

sleep 10
echo "Continuing..."
sleep 1

EOF
```

Собираем initrd: 
```console
[root@lvm ~]# dracut -fv
Executing: /sbin/dracut -fv
dracut module 'busybox' will not be installed, because command 'busybox' could not be found!
dracut module 'crypt' will not be installed, because command 'cryptsetup' could not be found!
dracut module 'dmraid' will not be installed, because command 'dmraid' could not be found!
dracut module 'dmsquash-live-ntfs' will not be installed, because command 'ntfs-3g' could not be found!
dracut module 'multipath' will not be installed, because command 'multipath' could not be found!
dracut module 'busybox' will not be installed, because command 'busybox' could not be found!
dracut module 'crypt' will not be installed, because command 'cryptsetup' could not be found!
dracut module 'dmraid' will not be installed, because command 'dmraid' could not be found!
dracut module 'dmsquash-live-ntfs' will not be installed, because command 'ntfs-3g' could not be found!
dracut module 'multipath' will not be installed, because command 'multipath' could not be found!
*** Including module: bash ***
*** Including module: pinguin ***
...
```

![dracut](https://github.com/sinist3rr/otus-linux/blob/master/HW07/images/dracut.png)


### Добавление ssh в initrd

Имеем Centos установленный на зашифрованном разделе LUKS (и корень тоже). 
В результате при каждом включении сервера нужно набирать пароль:


![luks](https://github.com/sinist3rr/otus-linux/blob/master/HW07/images/luks.png)

Было бы удобно если бы была возможность ввести ключ удаленно по ssh. 
Для это нужно добавить модуль в initrd. 
Чтобы установить специальный модуль нужно добавить репозиторий: 
```console
yum install wget -y
wget -O /etc/yum.repos.d/rbu-dracut-crypt-ssh-epel-7.repo https://copr.fedorainfracloud.org/coprs/rbu/dracut-crypt-ssh/repo/epel-7/rbu-dracut-crypt-ssh-epel-7.repo
yum install dracut-crypt-ssh -y
```

Нужно дописать новые параметры, которые предоставит модуль (rd.neednet=1 ip=dhcp):
```console
vi /etc/default/grub
GRUB_CMDLINE_LINUX="crashkernel=auto rd.neednet=1 ip=dhcp rd.luks.uuid=luks-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

grub2-mkconfig -o /etc/grub2.cfg 
```

В конфиге установленного модуля нужно прописать пути к ssh ключам: 
```console
vi /etc/dracut.conf.d/crypt-ssh.conf

dropbear_acl="/etc/dropbear/keys/authorized_keys"
dropbear_ecdsa_key="/etc/dropbear/keys/ssh_ecdsa_key"
dropbear_rsa_key="/etc/dropbear/keys/ssh_rsa_key"
```

Создать каталоги для хранения ключей: 
```console
mkdir /etc/dropbear/keys/
chmod 700 /etc/dropbear/keys/
```

Создать ssh ключи: 

```console
ssh-keygen -t ecdsa -f /etc/dropbear/keys/ssh_ecdsa_key
ssh-keygen -t rsa -f /etc/dropbear/keys/ssh_rsa_key
chmod 400 /etc/dropbear/keys/*_key
chmod 444 /etc/dropbear/keys/*.pub
```

Свой открытый публичный ssh ключ нужно разместить тоже: 
```console
vi /etc/dropbear/keys/authorized_keys
```

Все настройки завершены, осталось только собрать initrd: 

```console
dracut -fv
```

После перезагрузки на первый взгляд ничего не изменлось, и на консоли висит все тоже предложение ввести пароль для расшифровывания ФС. 

Но если подключится по ssh, то можно посмотреть что на удаленной консоли (команда console-peek) или расшифровать диск (console_auth): 

```console
$ssh -p222 root@192.168.56.101
-sh-4.2# 
-sh-4.2# console_peek


Please enter passphrase for disk root (luks-94de567b-eb08-42fe-a448-0bbb1184da1a
)!:



-sh-4.2# console_auth
Passphrase: 
-sh-4.2# Connection to 192.168.56.101 closed by remote host.
Connection to 192.168.56.101 closed.
```

И система успешно загружается дальше, монтируется корневой раздел и всё происходит в штатном режиме.

