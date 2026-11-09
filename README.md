# os-security-labs

My lab work for the course "Information Security", Kazan Federal University, 2026 (variant 14).
The course manual was written for RHEL 6, Windows 7 and Windows Server 2008 R2 in VMware. I did not have VMware, so I repeated the labs on my own servers and adapted every step to current systems:

| Lab | Topic | Environment |
|---|---|---|
| 1 | Protection mechanisms of Linux | Ubuntu Server 22.04 LTS, kernel 5.15 |
| 2 | Protection mechanisms of Windows | Windows Server 2022, cloud VM (4 vCPU, 4 GB RAM) |
| 3 | Active Directory security | Same server promoted to domain controller |
| 4 | Network scanning and firewalls | Ubuntu (nmap, iptables) and Windows Server (wf.msc) |

Each folder has short notes in English and the configs or commands I used. Full reports with screenshots were submitted to the university in Russian.

## Lab 1. Linux
- Users and groups: `useradd`, `usermod -aG`, `passwd -d` (empty password shown as a vulnerability). Hashes in `/etc/shadow` use yescrypt (`$y$`).
- Password policy through PAM: `pam_pwquality` (length, character classes, retries) and `/etc/login.defs` (password age). Weak passwords are rejected.
- Discretionary access control: owner, group, others; owner rights have priority over group rights; root is not restricted.
- Found in practice: in `/tmp` the kernel option `fs.protected_regular` blocks opening other users' files with `O_CREAT` even when file permissions allow it.
- Logging: rsyslog rules that send `auth` events to a separate file.

Files: [`lab1-linux/pwquality.conf`](lab1-linux/pwquality.conf), [`lab1-linux/rsyslog-security.conf`](lab1-linux/rsyslog-security.conf), [`lab1-linux/commands.sh`](lab1-linux/commands.sh)

## Lab 2. Windows
- Local users and UAC: a member of `Users` cannot create accounts, UAC asks for administrator credentials.
- NTFS permissions with disabled inheritance.
- Local security policy: password length and complexity.
- Security template `TestTemplate14.inf`: logon banner, hide last user name, restricted groups, disabled Print Spooler (no Telnet service in Server 2022).
- Audit: `auditpol` and SACL on a file, events 4656 / 4663 in the Security log.

Files: [`lab2-windows/audit.ps1`](lab2-windows/audit.ps1)

## Lab 3. Active Directory
- AD DS role, new forest `domain.local` (in Server 2022 `dcpromo` is replaced by the configuration wizard).
- Domain user with logon hours Mon-Fri 8:00-18:00.
- Group scheme: user -> global group -> domain local group -> resource.
- OU with a GPO that imports the security template from lab 2.

Main conclusion: a mistake in a template linked through GPO is applied to every computer in the OU, so templates must be tested before linking.

Files: [`lab3-ad/ad-setup.ps1`](lab3-ad/ad-setup.ps1)

## Lab 4. Network scanning and firewalls
- nmap 7.80 against my own server only: `-sT`, `-sS`, `-sF`, `-sX`, `-sN`, `-sO`, `-sA`. Open ports matched `ss -tlnp` (22, 80, 443, 5432 on localhost).
- FIN / Xmas / NULL give `open|filtered`: an open port does not answer, so it cannot be told apart from a filtered one.
- Windows Defender Firewall: inbound rule for TCP 80, checked with `Test-NetConnection`.
- iptables: DROP rule for ICMP in INPUT and FORWARD, 100% packet loss, connectivity restored after deleting the rule.

Lesson from practice: on a remote server allow SSH first, then add deny rules. Otherwise you lock yourself out.

Files: [`lab4-network/iptables-icmp.sh`](lab4-network/iptables-icmp.sh), [`lab4-network/nmap-scans.sh`](lab4-network/nmap-scans.sh)

## Reference
Abdullin R.M., Ivanov K.V., Ildiryakov V.R. Information protection in corporate information systems and personal data systems. Practical classes. Kazan Federal University, 2016.
