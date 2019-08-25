#!/bin/bash

yum -y install epel-release

yum -y install createrepo httpd rpm-build wget
rpm -ivh https://nginx.org/packages/centos/7/SRPMS/nginx-1.16.1-1.el7.ngx.src.rpm

# nginx dependecies
yum-builddep /root/rpmbuild/SPECS/nginx.spec -y
wget https://www.openssl.org/source/latest.tar.gz -P /root/rpmbuild/SOURCES/
mv /root/rpmbuild/SOURCES/latest.tar.gz /root/rpmbuild/SOURCES/openssl-1.1.1c.tar.gz

# modify SPEC file
sed -i '/Source13/a Source14: openssl-1.1.1c.tar.gz' /root/rpmbuild/SPECS/nginx.spec
sed -i '/%setup -q/a tar xvzf %SOURCE14' /root/rpmbuild/SPECS/nginx.spec
sed -i 's|--group=%{nginx_group}|--with-openssl=./openssl-1.1.1c|' /root/rpmbuild/SPECS/nginx.spec

# make rpm packet
rpmbuild --ba /root/rpmbuild/SPECS/nginx.spec

# create rpm repo
[[ -d /opt/myrepo ]] || mkdir /opt/myrepo
cp /root/rpmbuild/RPMS/x86_64/nginx-1.16.1-1.el7.ngx.x86_64.rpm /opt/myrepo/
createrepo /opt/myrepo/
ln -s /opt/myrepo/ /var/www/html/repo

systemctl enable --now httpd

