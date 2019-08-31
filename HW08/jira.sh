#!/bin/bash

yum -y install epel-release
yum -y install wget java-11-openjdk

# donwload and install jira
wget https://product-downloads.atlassian.com/software/jira/downloads/atlassian-jira-core-8.3.3-x64.bin -P /root/
chmod +x /root/atlassian-jira-core-8.3.3-x64.bin


cat << EOF > /root/response.varfile
# install4j response file for JIRA Core 8.3.3
app.install.service$Boolean=true
existingInstallationDir=/opt/JIRA Core
launch.application$Boolean=false
sys.adminRights$Boolean=true
sys.confirmedUpdateInstallationString=false
sys.installationDir=/opt/atlassian/jira
sys.languageId=en
EOF


# run Unattended jira installation
/root/atlassian-jira-core-8.3.3-x64.bin -q -varfile /root/response.varfile


# set permissions
chown -R jira:jira /opt/atlassian/jira/

# create jira unit file

cat << EOF > /etc/systemd/system/jira.service
[Unit]
Description=JIRA Service
After=network.target
Documentation=https://community.atlassian.com

[Service]
Type=forking
User=jira
Group=jira

PIDFile=/opt/atlassian/jira/work/catalina.pid

Environment=CATALINA_HOME=/opt/atlassian/jira
Environment=CATALINA_BASE=/opt/atlassian/jira
Environment=CATALINA_TMPDIR=/opt/atlassian/jira/temp
Environment=JIRA_HOME=/opt/atlassian/jira/atlassian-jira/
Environment='CATALINA_OPTS=-Xms1024M -Xmx1024M -server -XX:+UseParallelGC -XX:MaxPermSize=192m'
Environment=JRE_HOME=/opt/atlassian/jira/jre/
Environment=CLASSPATH=/opt/atlassian/jira/bin/bootstrap.jar:/opt/atlassian/jira/bin/tomcat-juli.jar
Environment=CATALINA_PID=/opt/atlassian/jira/work/catalina.pid

ExecStart=/opt/atlassian/jira/bin/start-jira.sh
ExecStop=/opt/atlassian/jira/bin/stop-jira.sh

[Install]
WantedBy=multi-user.target
EOF

# run jira

systemctl daemon-reload
systemctl start jira

