# Ansible

Задание:  
используя Ansible необходимо развернуть nginx со следующими условиями:
- необходимо использовать модуль yum/apt
- конфигурационные файлы должны быть взяты из шаблона jinja2 с перемененными
- после установки nginx должен быть в режиме enabled в systemd
- должен быть использован notify для старта nginx после установки
- сайт должен слушать на нестандартном порту - 8080, для этого использовать переменные в Ansible
* cделать все это с использованием Ansible роли
---

### Реализовано в виде ansible роли

Запускаем и смотрим:


```console

vagrant up
Bringing machine 'deb' up with 'virtualbox' provider...
Bringing machine 'rpm' up with 'virtualbox' provider...
...skipped...

==> deb: Running provisioner: ansible...
Vagrant has automatically selected the compatibility mode '2.0'
according to the Ansible version installed (2.8.4).

    deb: Running ansible-playbook...

PLAY [setup nginx] *************************************************************

TASK [Gathering Facts] *********************************************************
ok: [deb]

TASK [nginx : include_tasks] ***************************************************
included: /home/sinister/VProj/otus-linux/HW09/provision/roles/nginx/tasks/debian.yml for deb

TASK [nginx : install nginx] ***************************************************
 [WARNING]: Updating cache and auto-installing missing dependency: python-apt

 [WARNING]: Could not find aptitude. Using apt-get instead

changed: [deb]

TASK [nginx : deploy nginx config] *********************************************
changed: [deb]

TASK [nginx : deploy index html] ***********************************************
changed: [deb]

TASK [nginx : include_tasks] ***************************************************
skipping: [deb]

RUNNING HANDLER [nginx : restart nginx] ****************************************
changed: [deb]

TASK [nginx : test nginx port] *************************************************
ok: [deb]

TASK [nginx : test nginx index page] *******************************************
ok: [deb]

TASK [nginx : debug] ***********************************************************
ok: [deb] => {
    "ss_output.stdout": "tcp     LISTEN   0        128              0.0.0.0:8080          0.0.0.0:*       users:((\"nginx\",pid=2805,fd=6),(\"nginx\",pid=2804,fd=6),(\"nginx\",pid=2803,fd=6)) ino:24586 sk:2 <->"
}

TASK [nginx : debug] ***********************************************************
ok: [deb] => {
    "curl_output.stdout": "# Ansible managed\n\n<html>\n<head>\n<h3> deb nginx is up and running!</h3>\n</head>\n<htlm/>"
}

PLAY RECAP *********************************************************************
deb                        : ok=10   changed=4    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   

==> rpm: Running provisioner: ansible...
Vagrant has automatically selected the compatibility mode '2.0'
according to the Ansible version installed (2.8.4).

    rpm: Running ansible-playbook...

PLAY [setup nginx] *************************************************************

TASK [Gathering Facts] *********************************************************
ok: [rpm]

TASK [nginx : include_tasks] ***************************************************
skipping: [rpm]

TASK [nginx : include_tasks] ***************************************************
included: /home/sinister/VProj/otus-linux/HW09/provision/roles/nginx/tasks/redhat.yml for rpm

TASK [nginx : install common packages] *****************************************
changed: [rpm]

TASK [nginx : disable selinux] *************************************************
 [WARNING]: SELinux state temporarily changed from 'enforcing' to 'permissive'.
State change will take effect next reboot.

changed: [rpm]

TASK [nginx : install the packages from epel repo] *****************************
changed: [rpm]

TASK [nginx : deploy nginx config] *********************************************
changed: [rpm]

TASK [nginx : deploy index html] ***********************************************
changed: [rpm]

RUNNING HANDLER [nginx : restart nginx] ****************************************
changed: [rpm]

TASK [nginx : test nginx port] *************************************************
ok: [rpm]

TASK [nginx : test nginx index page] *******************************************
ok: [rpm]

TASK [nginx : debug] ***********************************************************
ok: [rpm] => {
    "ss_output.stdout": "tcp    LISTEN     0      128       *:8080                  *:*                   users:((\"nginx\",pid=6511,fd=6),(\"nginx\",pid=6510,fd=6)) ino:35346 sk:ffff9f82fb9a8f80 <->"
}

TASK [nginx : debug] ***********************************************************
ok: [rpm] => {
    "curl_output.stdout": "# Ansible managed\n\n<html>\n<head>\n<h3> rpm nginx is up and running!</h3>\n</head>\n<htlm/>"
}

PLAY RECAP *********************************************************************
rpm                        : ok=12   changed=6    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   

```

Видим, что сразу в конце провижининга выполняются тесты, которые проверяют чтобы nginx был запущен на порту 8080 и была измененная страница index.html.

