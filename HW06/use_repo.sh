#!/bin/bash

cat << EOF > /etc/yum.repos.d/myrepo.repo
[repo_server-repo]
name=My RPM NGINX Package Repo
baseurl=http://192.168.56.10/repo
enabled=1
priority=10
gpgcheck=0
EOF

