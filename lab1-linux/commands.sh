#!/usr/bin/env bash
# Lab 1: accounts, groups and discretionary access control on Ubuntu 22.04.
# Passwords are set interactively, not stored in this file.
set -e

cat /etc/os-release | head -2; uname -r

# users and group
sudo useradd -m -s /bin/bash -u 1014 user1 && sudo passwd user1
sudo useradd -m -s /bin/bash user2 && sudo passwd -d user2      # empty password: shown as a vulnerability
sudo useradd -m -s /bin/bash user3 && sudo passwd user3
sudo groupadd testgroup
sudo usermod -aG testgroup user2      # -a is important: without it other groups are removed
sudo usermod -aG testgroup user3
id user1; id user2; id user3
sudo grep -E '^user[123]:' /etc/shadow | cut -d: -f1,2 | sed 's/:\(.\{8\}\).*/:\1.../'   # $y$ = yescrypt

# password policy
sudo apt install -y libpam-pwquality
sudo cp pwquality.conf /etc/security/pwquality.conf
grep pam_pwquality /etc/pam.d/common-password

# discretionary access: file readable by the group, not by others
sudo -u user2 bash -c 'echo secret > /tmp/shared.txt && chgrp testgroup /tmp/shared.txt && chmod 640 /tmp/shared.txt'
sudo -u user3 cat /tmp/shared.txt     # allowed: member of testgroup
sudo -u user1 cat /tmp/shared.txt || echo "user1: permission denied (expected)"

# /tmp specifics found during the lab
sysctl fs.protected_regular           # 2 on Ubuntu: O_CREAT on other users' files in sticky dirs is denied

# logging
sudo cp rsyslog-security.conf /etc/rsyslog.d/50-security.conf
sudo systemctl restart rsyslog
logger -p auth.notice "lab1 test"; sudo tail -n 2 /var/log/security1
