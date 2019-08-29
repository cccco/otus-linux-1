# Работа с загрузчиком Linux 

Задания: 
1. Попасть в систему без пароля несколькими способами 
2. Установить систему с LVM, после чего переименовать VG 
3. Добавить модуль в initrd 

4. (*) Сконфигурировать систему без отдельного раздела с /boot, а только с LVM  
---

### 4. (*) Сконфигурировать систему без отдельного раздела с /boot, а только с LVM  

Используется Vagrantfile из ДЗ про LVM: 

```console
[root@lvm ~]# lsblk 
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
```

Добавляем репозиторий c пропатченным grub: 

```console
cat <<\EOT >> /etc/yum.repos.d/grub.repo
[grub]
name=grub with lvm
baseurl=https://yum.rumyantsev.com/centos/$releasever/$basearch/
enabled=1
gpgcheck=0
EOT
```

Обновляем grub: 

```console
[root@lvm ~]# yum update grub2
```

Подготавливаем специальную область для установки grub на пустых дисках: 

```console
[root@lvm ~]# pvcreate --bootloaderareasize 1m /dev/sd{b,c,d,e}
  Physical volume "/dev/sdb" successfully created.
  Physical volume "/dev/sdc" successfully created.
  Physical volume "/dev/sdd" successfully created.
  Physical volume "/dev/sde" successfully created.
```

Создаем LVM на пустых дисках: 

```console
[root@lvm ~]# vgcreate VolGroup01 /dev/sd{b,c,d,e}
  Volume group "VolGroup01" successfully created

[root@lvm ~]# lvcreate -L 1g VolGroup01 -n swap
  Logical volume "swap" created.

[root@lvm ~]# lvcreate -l 90%FREE VolGroup01 -n root
  Logical volume "root" created.

[root@lvm ~]# mkfs.ext4 /dev/VolGroup01/root
[root@lvm ~]# mkswap /dev/VolGroup01/swap
```

Переносим все файлы со старого диска на новые: 

```console
[root@lvm ~]# mkdir /mnt/oldroot/
[root@lvm ~]# mkdir /mnt/newroot/
[root@lvm ~]# mount -o bind / /mnt/oldroot/
[root@lvm ~]# mount -o bind /boot/ /mnt/oldroot/boot/
[root@lvm ~]# mount /dev/VolGroup01/root /mnt/newroot/
[root@lvm ~]# rsync -avx /mnt/oldroot/ /mnt/newroot/
```

Меняем записи в новом fstab: 

```console
[root@lvm ~]# blkid 
/dev/sda2: UUID="570897ca-e759-4c81-90cf-389da6eee4cc" TYPE="xfs" 
/dev/sda3: UUID="vrrtbx-g480-HcJI-5wLn-4aOf-Olld-rC03AY" TYPE="LVM2_member" 
/dev/sdb: UUID="1tHa3z-P5Ln-hN9f-NrQE-AU4d-0Wv3-llm6tJ" TYPE="LVM2_member" 
/dev/sdc: UUID="F9TLe0-14sm-N02w-i4Iu-9BHd-pbyA-3Ffkuz" TYPE="LVM2_member" 
/dev/sdd: UUID="ma7btV-RroJ-uK1G-GBkS-KOcB-mp1J-oiSmRS" TYPE="LVM2_member" 
/dev/mapper/VolGroup00-LogVol00: UUID="b60e9498-0baa-4d9f-90aa-069048217fee" TYPE="xfs" 
/dev/sde: UUID="J9vjZj-vjU2-mx3W-JLsV-T5QA-EZCF-gf1Beo" TYPE="LVM2_member" 
/dev/mapper/VolGroup00-LogVol01: UUID="c39c5bed-f37c-4263-bee8-aeb6a6659d7b" TYPE="swap" 
/dev/mapper/VolGroup01-swap: UUID="02c855c0-1479-4840-9970-8a99ca57dccf" TYPE="swap" 
/dev/mapper/VolGroup01-root: UUID="32ae8d75-b172-41d1-a1ba-a26b315bb74f" TYPE="ext4" 

[root@lvm ~]# vi /mnt/newroot/etc/fstab 

/dev/mapper/VolGroup01-root /                       ext4     defaults        0 0
/dev/mapper/VolGroup01-swap swap                    swap    defaults        0 0
[root@lvm ~]# 
```

Для установки загрузчика необходимо подмонтировать /dev, /sys, /proc и затем сделать chroot в новый корень: 

```console
[root@lvm ~]# mount -o bind /dev /mnt/newroot/dev
[root@lvm ~]# mount -o bind /sys /mnt/newroot/sys
[root@lvm ~]# mount -o bind /proc /mnt/newroot/proc
[root@lvm ~]# chroot /mnt/newroot/
```

Редактируем конфиг grub: 

```console
[root@lvm /]# vi /etc/default/grub 
GRUB_CMDLINE_LINUX="no_timer_check console=tty0 console=ttyS0,115200n8 net.ifnames=0 biosdevname=0 elevator=noop crashkernel=auto rd.lvm.lv=VolGroup01/root rd.lvm.lv=VolGroup01/swap rhgb quiet"
```

Теперь можно устанавлить grub на все диски: 

```console
[root@lvm /]# grub2-install  /dev/sdb
[root@lvm /]# grub2-install  /dev/sdc
[root@lvm /]# grub2-install  /dev/sdd
[root@lvm /]# grub2-install  /dev/sde
[root@lvm /]# grub2-mkconfig -o /boot/grub2/grub.cfg
```

Все готово, можно отключать старый диск и пробовать загрузится на LVM. 

*Прим. Пришлось еще выключить selinux, все загружалось, но не давало залогинится*: 

```console
[root@lvm ~]# vi /etc/selinux/config 

SELINUX=disabled
```

После перезагрузки: 

```console
[root@lvm ~]# lsblk 
NAME              MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                 8:0    0   10G  0 disk 
├─VolGroup01-root 253:0    0 11.7G  0 lvm  /
└─VolGroup01-swap 253:1    0    1G  0 lvm  [SWAP]
sdb                 8:16   0    2G  0 disk 
└─VolGroup01-root 253:0    0 11.7G  0 lvm  /
sdc                 8:32   0    1G  0 disk 
└─VolGroup01-root 253:0    0 11.7G  0 lvm  /
sdd                 8:48   0    1G  0 disk 
sr0                11:0    1 1024M  0 rom  

[root@lvm ~]# lvs
  LV   VG         Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root VolGroup01 -wi-ao---- 11.68g                                                    
  swap VolGroup01 -wi-ao----  1.00g       

[root@lvm ~]# findmnt 
TARGET                                SOURCE     FSTYPE     OPTIONS
/                                     /dev/mapper/VolGroup01-root
                                                 ext4       rw,relatime,data=ordered
├─/sys                                sysfs      sysfs      rw,nosuid,nodev,noexec,relatime
│ ├─/sys/kernel/security              securityfs securityfs rw,nosuid,nodev,noexec,relatime
│ ├─/sys/fs/cgroup                    tmpfs      tmpfs      ro,nosuid,nodev,noexec,mode=755
│ │ ├─/sys/fs/cgroup/systemd          cgroup     cgroup     rw,nosuid,nodev,noexec,relatime,xattr,release_agent=/usr/lib/systemd/systemd-cgroups-agent,na
│ │ ├─/sys/fs/cgroup/pids             cgroup     cgroup     rw,nosuid,nodev,noexec,relatime,pids
│ │ ├─/sys/fs/cgroup/cpu,cpuacct      cgroup     cgroup     rw,nosuid,nodev,noexec,relatime,cpuacct,cpu
│ │ ├─/sys/fs/cgroup/net_cls,net_prio cgroup     cgroup     rw,nosuid,nodev,noexec,relatime,net_prio,net_cls
│ │ ├─/sys/fs/cgroup/perf_event       cgroup     cgroup     rw,nosuid,nodev,noexec,relatime,perf_event
│ │ ├─/sys/fs/cgroup/hugetlb          cgroup     cgroup     rw,nosuid,nodev,noexec,relatime,hugetlb
│ │ ├─/sys/fs/cgroup/memory           cgroup     cgroup     rw,nosuid,nodev,noexec,relatime,memory
│ │ ├─/sys/fs/cgroup/cpuset           cgroup     cgroup     rw,nosuid,nodev,noexec,relatime,cpuset
│ │ ├─/sys/fs/cgroup/devices          cgroup     cgroup     rw,nosuid,nodev,noexec,relatime,devices
│ │ ├─/sys/fs/cgroup/blkio            cgroup     cgroup     rw,nosuid,nodev,noexec,relatime,blkio
│ │ └─/sys/fs/cgroup/freezer          cgroup     cgroup     rw,nosuid,nodev,noexec,relatime,freezer
│ ├─/sys/fs/pstore                    pstore     pstore     rw,nosuid,nodev,noexec,relatime
│ ├─/sys/kernel/debug                 debugfs    debugfs    rw,relatime
│ └─/sys/kernel/config                configfs   configfs   rw,relatime
├─/proc                               proc       proc       rw,nosuid,nodev,noexec,relatime
│ └─/proc/sys/fs/binfmt_misc          systemd-1  autofs     rw,relatime,fd=26,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=10442
├─/dev                                devtmpfs   devtmpfs   rw,nosuid,size=111984k,nr_inodes=27996,mode=755
│ ├─/dev/shm                          tmpfs      tmpfs      rw,nosuid,nodev
│ ├─/dev/pts                          devpts     devpts     rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000
│ ├─/dev/hugepages                    hugetlbfs  hugetlbfs  rw,relatime
│ └─/dev/mqueue                       mqueue     mqueue     rw,relatime
├─/run                                tmpfs      tmpfs      rw,nosuid,nodev,mode=755
│ └─/run/user/1000                    tmpfs      tmpfs      rw,nosuid,nodev,relatime,size=24140k,mode=700,uid=1000,gid=1000
└─/var/lib/nfs/rpc_pipefs             sunrpc     rpc_pipefs rw,relatime
```

