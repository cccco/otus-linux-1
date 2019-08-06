# Работа с LVM

Задание:
на имеющемся образе
/dev/mapper/VolGroup00-LogVol00 38G 738M 37G 2% /

* уменьшить том под / до 8G
* выделить том под /var
* /var - сделать в mirror
* /home - сделать том для снэпшотов
* прописать монтирование в fstab
* сгенерить файлы в /home/
* снять снэпшот
* удалить часть файлов
* восстановится со снэпшота


---

### Уменьшаем LVM том корневого раздела до 8 ГБ 

Для этого сначала готовим новый том на диске /dev/sdb 

```console
[root@lvm ~]# pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.

[root@lvm ~]# pvs
  PV         VG         Fmt  Attr PSize   PFree 
  /dev/sda3  VolGroup00 lvm2 a--  <38.97g     0 
  /dev/sdb              lvm2 ---   10.00g 10.00g

[root@lvm ~]# vgcreate vg_root /dev/sdb
  Volume group "vg_root" successfully created

[root@lvm ~]# vgs
  VG         #PV #LV #SN Attr   VSize   VFree  
  VolGroup00   1   2   0 wz--n- <38.97g      0 
  vg_root      1   0   0 wz--n- <10.00g <10.00g

[root@lvm ~]# lvcreate -n lv_root -l +100%FREE /dev/vg_root
  Logical volume "lv_root" created.

[root@lvm ~]# lvs
  LV       VG         Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  LogVol00 VolGroup00 -wi-ao---- <37.47g                                                    
  LogVol01 VolGroup00 -wi-ao----   1.50g                                                    
  lv_root  vg_root    -wi-a----- <10.00g                                                    

[root@lvm ~]# mkfs.xfs /dev/vg_root/lv_root 
meta-data=/dev/vg_root/lv_root   isize=512    agcount=4, agsize=655104 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=2620416, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0

[root@lvm ~]# mount /dev/vg_root/lv_root /mnt/
```

Переносим данные с корня на /mnt 

```console
[root@lvm ~]# xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
xfsrestore: using file dump (drive_simple) strategy
...
xfsdump: media file size 1061618416 bytes
xfsdump: dump size (non-dir files) : 1035084256 bytes
xfsdump: dump complete: 17 seconds elapsed
xfsdump: Dump Status: SUCCESS
xfsrestore: restore complete: 17 seconds elapsed
xfsrestore: Restore Status: SUCCESS
```

Переносим grub 

```console
[root@lvm ~]# for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
[root@lvm ~]# chroot /mnt/
[root@lvm /]# grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-3.10.0-862.2.3.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-862.2.3.el7.x86_64.img
done
[root@lvm /]# cd boot/
[root@lvm boot]#  for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done
*** Creating image file ***
*** Creating image file done ***
*** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***
```
Меняем в конфиге загрузчика имя тома 

```console
[root@lvm boot]# sed -i 's/VolGroup00\/LogVol00/vg_root\/lv_root/g' /boot/grub2/grub.cfg
```

Перезагружаемся и проверяем
```console 
[root@lvm boot]# reboot
[root@lvm ~]$ lsblk | grep root
└─vg_root-lv_root       253:0    0   10G  0 lvm  /
```

Удаляем старый том, создаем новый объемом в 8 ГБ 

```console 
[root@lvm ~]# lvremove /dev/VolGroup00/LogVol00
Do you really want to remove active logical volume VolGroup00/LogVol00? [y/n]: y
  Logical volume "LogVol00" successfully removed

[root@lvm ~]# lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
  Logical volume "LogVol00" created.

[root@lvm ~]# lvs
  LV       VG         Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  LogVol00 VolGroup00 -wi-a-----   8.00g                                                    
  LogVol01 VolGroup00 -wi-ao----   1.50g                                                    
  lv_root  vg_root    -wi-ao---- <10.00g                                                    

[root@lvm ~]# mkfs.xfs /dev/VolGroup00/LogVol00
[root@lvm ~]# mount /dev/VolGroup00/LogVol00 /mnt
```

Тем же способом переносим раздел обратно

```console
[root@lvm ~]# xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt
...
xfsdump: dump complete: 18 seconds elapsed
xfsdump: Dump Status: SUCCESS
xfsrestore: restore complete: 18 seconds elapsed
xfsrestore: Restore Status: SUCCESS

[root@lvm ~]# for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
[root@lvm ~]# chroot /mnt/
[root@lvm /]# grub2-mkconfig -o /boot/grub2/grub.cfg
[root@lvm /]# cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done
```

---
### Зеркалирование раздела /var

Создаем зеркало на двух следующих дисках: 

```console
[root@lvm boot]# pvcreate /dev/sdc /dev/sdd
  Physical volume "/dev/sdc" successfully created.
  Physical volume "/dev/sdd" successfully created.

[root@lvm boot]# vgcreate vg_var /dev/sdc /dev/sdd
  Volume group "vg_var" successfully created

[root@lvm boot]# vgs
  VG         #PV #LV #SN Attr   VSize   VFree  
  VolGroup00   1   2   0 wz--n- <38.97g <29.47g
  vg_root      1   1   0 wz--n- <10.00g      0 
  vg_var       2   0   0 wz--n-   2.99g   2.99g

[root@lvm boot]# lvcreate -L 900M -m1 -n lv_var vg_var
[root@lvm boot]# mkfs.ext4 /dev/vg_var/lv_var
[root@lvm boot]# mount /dev/vg_var/lv_var /mnt
```

Копируем на зеркало содержимое раздела /var: 

```console
[root@lvm boot]# rsync -avHPSAX /var/ /mnt/
sent 168,956,982 bytes  received 307,641 bytes  67,705,849.20 bytes/sec
total size is 168,447,163  speedup is 1.00

[root@lvm boot]# rm -rf /var/*
[root@lvm boot]# umount /mnt/
[root@lvm boot]# mount /dev/vg_var/lv_var /var
```

Добавляем запись в fstab: 

```console
[root@lvm boot]# echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab
```

Проверяем после перезагрузки 

```console
[vagrant@lvm ~]$ lsblk 
NAME                     MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                        8:0    0   40G  0 disk 
├─sda1                     8:1    0    1M  0 part 
├─sda2                     8:2    0    1G  0 part /boot
└─sda3                     8:3    0   39G  0 part 
  ├─VolGroup00-LogVol00  253:0    0    8G  0 lvm  /
  └─VolGroup00-LogVol01  253:1    0  1.5G  0 lvm  [SWAP]
sdb                        8:16   0   10G  0 disk 
└─vg_root-lv_root        253:7    0   10G  0 lvm  
sdc                        8:32   0    2G  0 disk 
├─vg_var-lv_var_rmeta_0  253:2    0    4M  0 lvm  
│ └─vg_var-lv_var        253:6    0  900M  0 lvm  /var
└─vg_var-lv_var_rimage_0 253:3    0  900M  0 lvm  
  └─vg_var-lv_var        253:6    0  900M  0 lvm  /var
sdd                        8:48   0    1G  0 disk 
├─vg_var-lv_var_rmeta_1  253:4    0    4M  0 lvm  
│ └─vg_var-lv_var        253:6    0  900M  0 lvm  /var
└─vg_var-lv_var_rimage_1 253:5    0  900M  0 lvm  
  └─vg_var-lv_var        253:6    0  900M  0 lvm  /var
sde                        8:64   0    1G  0 disk 
```

Удаляем временный раздел, который использовался под временный корень: 

```console
[root@lvm ~]# lvremove /dev/vg_root/lv_root
Do you really want to remove active logical volume vg_root/lv_root? [y/n]: y
  Logical volume "lv_root" successfully removed

[root@lvm ~]# vgremove /dev/vg_root
  Volume group "vg_root" successfully removed

[root@lvm ~]# pvremove /dev/sdb
  Labels on physical volume "/dev/sdb" successfully wiped.
```

---

### Выделяем том под /home

```console
[root@lvm ~]# lvcreate -n lv_home -L 2G /dev/VolGroup00
  Logical volume "lv_home" created.

[root@lvm ~]# lvs
  LV       VG         Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  LogVol00 VolGroup00 -wi-ao----   8.00g                                                    
  LogVol01 VolGroup00 -wi-ao----   1.50g                                                    
  lv_home  VolGroup00 -wi-a-----   2.00g                                                    
  lv_var   vg_var     rwi-aor--- 900.00m                                    100.00          
```

Копируем текущий /home 

```console
[root@lvm ~]# rsync -av /home/* /mnt/

sent 1,182 bytes  received 104 bytes  2,572.00 bytes/sec
total size is 831  speedup is 0.65

[root@lvm ~]# rm -rf /home/*
[root@lvm ~]# umount /mnt
[root@lvm ~]# mount /dev/VolGroup00/lv_home /home
```

Добавляем запись в fstab 

```console
[root@lvm ~]# echo "`blkid | grep home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab
```

Создаем файлы в /home 

```console
[root@lvm ~]# touch /home/file{1..200}
```

Создаем новый том для снапшотов 

```console
[root@lvm ~]# lvcreate -L 100MB -s -n home_snap /dev/VolGroup00/lv_home
  Rounding up size to full physical extent 128.00 MiB
  Logical volume "home_snap" created.
```

Удаляем большую часть файлов 

```console
[root@lvm ~]# rm -f /home/file{11..200}
[root@lvm ~]# ls /home/
file1  file10  file2  file3  file4  file5  file6  file7  file8  file9  vagrant
```

Восстанавливаемся со снапшота и проверяем наличие файлов 

```console
[root@lvm ~]# lvconvert --merge /dev/VolGroup00/home_snap
  Merging of volume VolGroup00/home_snap started.
  VolGroup00/lv_home: Merged: 100.00%

[root@lvm ~]# mount /home
[root@lvm ~]# ls /home/ | wc -l
201
```

