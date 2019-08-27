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

(Использовался VAgrantfile с задания по LVM) 

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

После переазгрузки: 

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

